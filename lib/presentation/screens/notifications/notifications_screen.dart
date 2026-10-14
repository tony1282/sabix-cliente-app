import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../models/notification_model.dart';
import '../../widgets/error_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      final provider = context.read<NotificationProvider>();

      if (userId != null) {
        provider.initialize(userId);
      } else {
        provider.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (!provider.hasUnread) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Marcar todas como leídas',
                icon: const Icon(Icons.done_all_rounded),
                onPressed: () => _markAllAsRead(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return ErrorState(
              message: provider.error!,
              onRetry: provider.refresh,
            );
          }

          if (provider.notifications.isEmpty) {
            return const _EmptyNotifications();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () => _openNotification(context, notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final provider = context.read<NotificationProvider>();

    if (!notification.isRead) {
      await provider.markAsRead(notification.id);
    }

    if (!mounted) return;

    final orderId = notification.orderId;
    if (orderId != null && orderId > 0) {
      context.push('/order/$orderId');
    }
  }

  Future<void> _markAllAsRead(BuildContext context) async {
    final success = await context.read<NotificationProvider>().markAllAsRead();

    if (!mounted || success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudieron marcar las notificaciones como leídas'),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final priorityColor = _priorityColor(notification.priority);

    return Material(
      color: isUnread
          ? AppColors.primary.withOpacity(0.04)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withOpacity(0.20)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _notificationIcon(notification.type),
                  color: priorityColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (notification.typeDisplay.isNotEmpty)
                          Expanded(
                            child: Text(
                              notification.typeDisplay,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        Text(
                          _timeLabel(notification),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (notification.orderId != null)
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 9),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(NotificationModel notification) {
    final timeAgo = notification.timeAgo?.trim();
    if (timeAgo != null && timeAgo.isNotEmpty) {
      return timeAgo;
    }

    final createdAt = notification.createdAt;
    if (createdAt == null) return '';

    final local = createdAt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 2:
        return AppColors.error;
      case 1:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _notificationIcon(String type) {
    if (type.startsWith('order_')) {
      return Icons.receipt_long_rounded;
    }

    if (type == 'promotion' || type == 'discount') {
      return Icons.local_offer_outlined;
    }

    return Icons.notifications_outlined;
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 54,
              color: AppColors.textLight,
            ),
            SizedBox(height: 14),
            Text(
              'Sin notificaciones',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Aquí aparecerán las novedades de tus pedidos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

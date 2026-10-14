import 'order_item_row.dart';
import 'order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../core/config/app_colors.dart';
import 'package:sabix_cliente_app/presentation/widgets/orders/rder_info_row.dart';

class OrderDetailContent extends StatelessWidget {
  final Order order;
  final VoidCallback? onChatWithDelivery;
  final bool isOpeningChat;

  const OrderDetailContent({
    super.key,
    required this.order,
    this.onChatWithDelivery,
    this.isOpeningChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInfoSection(),
          // El botón de chat solo aparece cuando hay un repartidor asignado
          if (order.deliveryPerson != null) ...[
            const SizedBox(height: 20),
            _buildDeliveryPersonSection(),
          ],
          const SizedBox(height: 20),
          if (order.items != null) ...[
            _buildProductsSection(),
            const SizedBox(height: 20),
          ],
          _buildSummarySection(),
          const SizedBox(height: 20),
          if (order.paymentMethod != null) _buildPaymentMethod(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #${order.id}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              OrderStatusBadge(status: order.status),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${order.totalItems} productos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Información del pedido ──────────────────────
  Widget _buildInfoSection() {
    final List<Widget> rows = [];

    // Restaurante
    rows.add(
      OrderInfoRow(
        icon: Icons.store_rounded,
        label: 'Restaurante',
        value: order.restaurantName,
      ),
    );
    rows.add(const SizedBox(height: 12));

    // Dirección
    if (order.deliveryAddress != null) {
      rows.add(
        OrderInfoRow(
          icon: Icons.location_on_rounded,
          label: 'Dirección de entrega',
          value: order.deliveryAddress!,
        ),
      );
      rows.add(const SizedBox(height: 12));
    }

    // Notas de entrega
    if (order.deliveryNotes != null && order.deliveryNotes!.isNotEmpty) {
      rows.add(
        OrderInfoRow(
          icon: Icons.note_rounded,
          label: 'Notas de entrega',
          value: order.deliveryNotes!,
        ),
      );
      rows.add(const SizedBox(height: 12));
    }

    // Fechas
    rows.add(
      OrderInfoRow(
        icon: Icons.calendar_today_rounded,
        label: 'Creado',
        value: _formatDateTime(order.createdAt),
      ),
    );
    if (order.confirmedAt != null) {
      rows.add(const SizedBox(height: 12));
      rows.add(
        OrderInfoRow(
          icon: Icons.check_circle_outline_rounded,
          label: 'Confirmado',
          value: _formatDateTime(order.confirmedAt!),
        ),
      );
    }
    if (order.deliveredAt != null) {
      rows.add(const SizedBox(height: 12));
      rows.add(
        OrderInfoRow(
          icon: Icons.done_all_rounded,
          label: 'Entregado',
          value: _formatDateTime(order.deliveredAt!),
        ),
      );
    }

    return _buildSection(title: 'Información del pedido', children: rows);
  }

  // ─── Repartidor asignado ──────────────────────────
  Widget _buildDeliveryPersonSection() {
    final deliveryName = order.deliveryPersonName?.isNotEmpty == true
        ? order.deliveryPersonName!
        : 'Repartidor';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Repartidor',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deliveryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: isOpeningChat ? null : onChatWithDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isOpeningChat
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(isOpeningChat ? 'Abriendo...' : 'Chatear'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Productos ─────────────────────────────────────
  Widget _buildProductsSection() {
    return _buildSection(
      title: 'Productos (${order.items!.length})',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.items!.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, i) {
            final item = order.items![i];
            return OrderItemRow(
              name: item.productName,
              quantity: item.quantity,
              price: item.productPrice,
              total: item.total,
            );
          },
        ),
      ],
    );
  }

  // ─── Resumen ──────────────────────────────────────
  Widget _buildSummarySection() {
    return _buildSection(
      title: 'Resumen',
      children: [
        _summaryRow('Subtotal', order.subtotal ?? 0),
        const Divider(height: 16),
        _summaryRow('Costo de envío', order.deliveryFee),
        const Divider(height: 16),
        _summaryRow('Total', order.total, isBold: true, isTotal: true),
      ],
    );
  }

  // ─── Método de pago ──────────────────────────────
  Widget _buildPaymentMethod() {
    final methodDisplay = _formatPaymentMethod(order.paymentMethod!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payment_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de pago',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  methodDisplay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  // ─── Widgets auxiliares ──────────────────────────
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPaymentMethod(String method) {
    // Solo mostramos "Tarjeta" (card)
    return 'Tarjeta';
  }
}

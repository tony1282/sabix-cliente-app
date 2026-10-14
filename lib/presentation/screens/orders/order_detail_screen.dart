import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/error_state.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order_model.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/orders/order_detail_content.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  bool _isOpeningChat = false;
  Order? _order;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orderId = int.tryParse(widget.orderId);
      if (orderId == null) throw Exception('ID inválido');
      final order = await context.read<OrderProvider>().fetchOrderDetail(
        orderId,
      );
      if (order == null) throw Exception('Pedido no encontrado');
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openChatWithDelivery() async {
    final order = _order;
    if (order == null || _isOpeningChat) return;

    setState(() => _isOpeningChat = true);
    try {
      final jwtToken = context.read<AuthProvider>().currentUser?.token ?? '';
      final conversation = await context.read<ChatProvider>().getOrCreateByOrder(
        order.id.toString(),
      );

      if (!mounted) return;

      if (conversation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el chat con el repartidor'),
          ),
        );
        return;
      }

      context.push(
        AppRouter.chat,
        extra: {
          'conversationId': conversation.id,
          'orderId': conversation.orderId.isEmpty
              ? order.id.toString()
              : conversation.orderId,
          'title': conversation.title,
          'jwtToken': jwtToken,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                  ),
                  const Text(
                    'Detalle del Pedido',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenido
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? ErrorState(message: _error!, onRetry: _loadOrder)
                  : _order != null
                  ? OrderDetailContent(
                      order: _order!,
                      onChatWithDelivery: _openChatWithDelivery,
                      isOpeningChat: _isOpeningChat,
                    )
                  : const Center(child: Text('Pedido no encontrado')),
            ),
          ],
        ),
      ),
    );
  }
}

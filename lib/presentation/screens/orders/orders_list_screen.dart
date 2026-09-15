import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order_model.dart';
import '../../../core/config/app_colors.dart';
import '../../widgets/orders/order_card.dart';
import '../../../core/providers/order_provider.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../widgets/orders/order_filter_chip.dart'; // ← Import corregido

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final filteredOrders = provider.getOrdersByStatus(_selectedFilter);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Pedidos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      onPressed: () => context.goToCart(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${provider.orders.length} pedidos totales',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filtros
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  OrderFilterChip(
                    label: 'Todos',
                    selected: _selectedFilter == 'Todos',
                    onTap: () => setState(() => _selectedFilter = 'Todos'),
                  ),
                  const SizedBox(width: 8),
                  OrderFilterChip(
                    label: 'Pendiente',
                    selected: _selectedFilter == 'pending',
                    onTap: () => setState(() => _selectedFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  OrderFilterChip(
                    label: 'Confirmado',
                    selected: _selectedFilter == 'confirmed',
                    onTap: () => setState(() => _selectedFilter = 'confirmed'),
                  ),
                  const SizedBox(width: 8),
                  OrderFilterChip(
                    label: 'En preparación',
                    selected: _selectedFilter == 'preparing',
                    onTap: () => setState(() => _selectedFilter = 'preparing'),
                  ),
                  const SizedBox(width: 8),
                  OrderFilterChip(
                    label: 'En camino',
                    selected: _selectedFilter == 'in_delivery',
                    onTap: () =>
                        setState(() => _selectedFilter = 'in_delivery'),
                  ),
                  const SizedBox(width: 8),
                  OrderFilterChip(
                    label: 'Entregado',
                    selected: _selectedFilter == 'delivered',
                    onTap: () => setState(() => _selectedFilter = 'delivered'),
                  ),
                  const SizedBox(width: 8),
                  OrderFilterChip(
                    label: 'Cancelado',
                    selected: _selectedFilter == 'cancelled',
                    onTap: () => setState(() => _selectedFilter = 'cancelled'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de pedidos
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? ErrorState(
                      message: provider.error!,
                      onRetry: () => provider.fetchOrders(),
                    )
                  : filteredOrders.isEmpty
                  ? EmptyState(
                      title: _selectedFilter == 'Todos'
                          ? 'Sin pedidos aún'
                          : 'Sin pedidos $_selectedFilter',
                      subtitle: '¡Haz tu primer pedido ahora!',
                      icon: Icons.receipt_long_rounded,
                      actionText: 'Explorar productos',
                      onAction: () => context.goToHome(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, i) {
                        final order = filteredOrders[i];
                        return OrderCard(
                          order: order,
                          onTap: () => context.push('/order/${order.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

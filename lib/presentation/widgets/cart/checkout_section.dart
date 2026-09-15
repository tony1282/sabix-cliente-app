import '../../routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/cart_provider.dart';

class CheckoutSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController notesController;
  final String paymentMethod;
  final bool showAddressForm;
  final VoidCallback onToggleAddressForm;
  final ValueChanged<String> onPaymentMethodChanged;

  const CheckoutSection({
    super.key,
    required this.addressController,
    required this.notesController,
    required this.paymentMethod,
    required this.showAddressForm,
    required this.onToggleAddressForm,
    required this.onPaymentMethodChanged,
  });

  static const List<Map<String, dynamic>> _paymentOptions = [
    {'value': 'cash', 'label': 'Efectivo', 'icon': Icons.payments_rounded},
    {'value': 'card', 'label': 'Tarjeta', 'icon': Icons.credit_card_rounded},
    {
      'value': 'online',
      'label': 'En línea',
      'icon': Icons.account_balance_wallet_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Botón mostrar dirección (colapsado) ──
          if (!showAddressForm)
            GestureDetector(
              onTap: onToggleAddressForm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_location_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Agregar dirección de entrega',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

          // ── Formulario de dirección, pago y notas ──
          if (showAddressForm) ...[
            _sectionLabel('Dirección de entrega', Icons.location_on_rounded),
            const SizedBox(height: 8),
            _buildStyledField(
              controller: addressController,
              hint: 'Calle, número, colonia, referencia',
              icon: Icons.home_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            _sectionLabel('Método de pago', Icons.payment_rounded),
            const SizedBox(height: 10),
            Row(
              children: _paymentOptions.map((option) {
                final isSelected = paymentMethod == option['value'];
                final isLast = option == _paymentOptions.last;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 8),
                    child: GestureDetector(
                      onTap: () =>
                          onPaymentMethodChanged(option['value'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.inputBorder,
                            width: isSelected ? 1.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              option['icon'] as IconData,
                              size: 22,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              option['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Notas adicionales', Icons.note_alt_rounded),
            const SizedBox(height: 8),
            _buildStyledField(
              controller: notesController,
              hint: 'Ej: timbre, piso, referencia (opcional)',
              icon: Icons.edit_note_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
          ],

          // ── Total ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withOpacity(0.12),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Botón checkout ──
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: cart.isLoading || cart.items.isEmpty
                  ? null
                  : () => _checkout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
                disabledBackgroundColor: AppColors.primary.withOpacity(0.25),
              ),
              child: cart.isLoading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Realizar Pedido',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widgets auxiliares ──────────────────────────
  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.7),
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.inputBg,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.inputFocus, width: 2),
        ),
      ),
    );
  }

  void _checkout(BuildContext context) async {
    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa una dirección de entrega'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final restaurantId = cart.restaurantId;
    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar el restaurante'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      return;
    }

    final items = cart.items
        .map(
          (item) => OrderItemRequest(
            productId: item.productId,
            quantity: item.quantity,
            notes: null,
          ),
        )
        .toList();

    final orderRequest = OrderCreateRequest(
      restaurant: restaurantId,
      items: items,
      deliveryAddress: addressController.text.trim(),
      deliveryNotes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      paymentMethod: paymentMethod,
    );

    final success = await cart.checkout(orderRequest);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido realizado con éxito! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      context.goToOrders();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.error ?? 'Error al crear el pedido'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }
  }
}

import 'cart_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/cart/cart_empty_state.dart';
import '../../../core/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (cart.items.isEmpty) {
              return const CartEmptyState();
            }
            return const CartContent();
          },
        ),
      ),
    );
  }
}

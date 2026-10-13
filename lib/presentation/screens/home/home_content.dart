import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../../models/product_model.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import 'package:sabix_cliente_app/core/config/app_colors.dart';
import 'package:sabix_cliente_app/presentation/widgets/home/widgets/search_bar.dart';
import 'package:sabix_cliente_app/presentation/widgets/home/widgets/home_header.dart';
import 'package:sabix_cliente_app/presentation/widgets/home/widgets/product_card.dart';
import 'package:sabix_cliente_app/presentation/widgets/home/widgets/category_chip.dart';

// presentation/screens/home/home_content.dart

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategory = 0;

  List<ProductModel> get _filteredProducts {
    final provider = context.watch<ProductProvider>();
    if (_selectedCategory == 0) return provider.products;
    final selectedCat = provider.categories.firstWhere(
      (cat) => cat.id == _selectedCategory,
      orElse: () => RestaurantCategoryModel(id: 0, name: ''),
    );
    if (selectedCat.id == 0) return provider.products;
    return provider.products.where((product) {
      if (product.categoryId != null) {
        return product.categoryId == selectedCat.id;
      }
      return product.categoryName == selectedCat.name;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.fetchCategories();
      p.searchProducts('');

      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<NotificationProvider>().initialize(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final filteredProducts = _filteredProducts;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          const SizedBox(height: 16),
          HomeSearchBar(
            controller: _searchController,
            onClear: () {
              _searchController.clear();
              provider.searchProducts('');
              setState(() {});
            },
            onSubmitted: (v) => provider.searchProducts(v),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (provider.categories.isNotEmpty) _buildCategoryList(provider),
          const SizedBox(height: 16),
          _buildProductCount(filteredProducts, provider),
          const SizedBox(height: 10),
          Expanded(child: _buildProductGrid(provider, filteredProducts)),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ProductProvider provider) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: provider.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final categoryId = isAll ? 0 : provider.categories[i - 1].id;
          final isSelected = _selectedCategory == categoryId;
          final label = isAll ? 'Todos' : provider.categories[i - 1].name;
          return CategoryChip(
            label: label,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedCategory = categoryId),
          );
        },
      ),
    );
  }

  Widget _buildProductCount(
    List<ProductModel> products,
    ProductProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        provider.isLoading ? 'Cargando...' : '${products.length} productos',
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildProductGrid(
    ProductProvider provider,
    List<ProductModel> products,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }
    if (provider.errorMessage != null) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.searchProducts(''),
      );
    }
    if (products.isEmpty) {
      return const EmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) => ProductCard(product: products[i]),
    );
  }
}

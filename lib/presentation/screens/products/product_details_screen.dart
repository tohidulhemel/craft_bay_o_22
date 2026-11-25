import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_assets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/product.dart';
import '../../../domain/repositories/catalog_repository.dart';
import '../../state/cart_state.dart';
import '../../state/product_details_state.dart';
import '../../state/wishlist_state.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/wishlist_toggle_helper.dart';

class ProductDetailsArgs {
  const ProductDetailsArgs({
    required this.productId,
    this.initialProduct,
  });

  final String productId;
  final Product? initialProduct;
}

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.args});

  final ProductDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailsState(context.read<CatalogRepository>())
        ..loadProduct(args.productId, initialProduct: args.initialProduct),
      child: _ProductDetailsView(productId: args.productId),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  const _ProductDetailsView({required this.productId});

  final String productId;

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductDetailsState>();
    final product = state.product;

    if (product == null && state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? 'Product not found.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => state.loadProduct(widget.productId),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 42),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final photos = product.photos;
    final totalPrice = product.currentPrice * state.quantity;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageHeader(
                    photos: photos,
                    controller: _imageController,
                    currentIndex: _imageIndex,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            QuantityStepper(
                              value: state.quantity,
                              onIncrement: state.incrementQuantity,
                              onDecrement: state.decrementQuantity,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.star,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.reviews,
                                arguments: product.id,
                              ),
                              child: const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: () =>
                                  toggleWishlistWithFeedback(context, product),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  context
                                          .watch<WishlistState>()
                                          .isWishlisted(product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (product.colors.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Color',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: product.colors.map((colorName) {
                              final selected = state.selectedColor == colorName;
                              final color = _resolveColor(colorName);
                              final isLight = color.computeLuminance() > 0.85;
                              return InkWell(
                                onTap: () => state.selectColor(colorName),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isLight
                                          ? AppColors.border
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: selected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: isLight
                                              ? AppColors.textDark
                                              : Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        if (product.sizes.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: product.sizes.map((size) {
                              final selected = state.selectedSize == size;
                              return InkWell(
                                onTap: () => state.selectSize(size),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textGrey,
                                    ),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 18),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'No description available.',
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomPriceBar(
            price: totalPrice,
            isAdding: context.watch<CartState>().isAdding,
            onAddToCart: () async {
              final cart = context.read<CartState>();
              final ok = await cart.addToCart(
                productId: product.id,
                quantity: state.quantity,
                color: state.selectedColor,
                size: state.selectedSize,
              );
              if (!context.mounted) return;
              if (ok) {
                SnackbarUtils.show(context, 'Added to cart.');
              } else {
                SnackbarUtils.show(
                  context,
                  cart.errorMessage ?? 'Could not add to cart.',
                  isError: true,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Color _resolveColor(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.startsWith('#')) {
      final hex = value.substring(1);
      final parsed = int.tryParse(
        hex.length == 6 ? 'FF$hex' : hex,
        radix: 16,
      );
      if (parsed != null) return Color(parsed);
    }

    const namedColors = <String, Color>{
      'black': Color(0xFF212121),
      'white': Colors.white,
      'red': Color(0xFFE53935),
      'blue': Color(0xFF1E88E5),
      'green': Color(0xFF43A047),
      'purple': Color(0xFF8E24AA),
      'gold': Color(0xFFD4AF37),
      'yellow': Color(0xFFFDD835),
      'orange': Color(0xFFFB8C00),
      'pink': Color(0xFFD81B60),
      'brown': Color(0xFF6D4C41),
      'grey': Color(0xFF9E9E9E),
      'gray': Color(0xFF9E9E9E),
      'teal': AppColors.primary,
      'navy': Color(0xFF1A237E),
    };
    return namedColors[value] ?? AppColors.primary;
  }
}

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({
    required this.photos,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> photos;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final itemCount = photos.isEmpty ? 1 : photos.length;

    return Container(
      height: 270,
      color: const Color(0xFFF3F4F6),
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: itemCount,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              if (photos.isEmpty) {
                return Center(
                  child: Image.asset(AppAssets.shoe, fit: BoxFit.contain),
                );
              }
              return CachedNetworkImage(
                imageUrl: photos[index],
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: AppColors.textGrey,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (itemCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < itemCount; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == i
                            ? AppColors.primary
                            : Colors.white,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomPriceBar extends StatelessWidget {
  const _BottomPriceBar({
    required this.price,
    required this.isAdding,
    required this.onAddToCart,
  });

  final num price;
  final bool isAdding;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 135,
              height: 44,
              child: ElevatedButton(
                onPressed: isAdding ? null : onAddToCart,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isAdding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add To Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

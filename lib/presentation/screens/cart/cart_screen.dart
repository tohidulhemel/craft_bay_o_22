import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/cart_item.dart';
import '../../state/cart_state.dart';
import '../../state/nav_state.dart';
import '../../widgets/quantity_stepper.dart';
import '../products/product_details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartState>().loadCart();
    });
  }

  Future<void> _updateQuantity(CartItem item, int nextQty) async {
    final ok = await context.read<CartState>().updateQuantity(item.id, nextQty);
    if (!ok && mounted) {
      final msg = context.read<CartState>().errorMessage ??
          'Could not update quantity.';
      SnackbarUtils.show(context, msg, isError: true);
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final ok = await context.read<CartState>().removeItem(item.id);
    if (!mounted) return;
    if (ok) {
      SnackbarUtils.show(context, 'Removed from cart.');
    } else {
      final msg = context.read<CartState>().errorMessage ??
          'Could not remove item.';
      SnackbarUtils.show(context, msg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CartState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.read<NavState>().goHome(),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<CartState>().loadCart(force: true),
              child: _buildList(state),
            ),
          ),
          _CartBottomBar(
            totalPrice: state.totalPrice,
            hasItems: state.items.isNotEmpty,
            onCheckout: () {
              if (state.items.isEmpty) {
                SnackbarUtils.show(
                  context,
                  'Your cart is empty.',
                  isError: true,
                );
                return;
              }
              SnackbarUtils.show(
                context,
                'Checkout & Orders will be connected in the next phase.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(CartState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => state.loadCart(force: true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'Your cart is empty.',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        final isMutating = state.isItemMutating(item.id);
        return _CartItemCard(
          item: item,
          isMutating: isMutating,
          onTap: () {
            if (item.product.id.isEmpty) return;
            Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: ProductDetailsArgs(
                productId: item.product.id,
                initialProduct: item.product,
              ),
            );
          },
          onIncrement: () => _updateQuantity(item, item.quantity + 1),
          onDecrement: () => _updateQuantity(item, item.quantity - 1),
          onRemove: () => _removeItem(item),
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.isMutating,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final bool isMutating;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.product.thumbnail;
    final attributes = <String>[
      if (item.color != null) 'Color: ${item.color}',
      if (item.size != null) 'Size: ${item.size}',
    ].join(', ');

    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: thumbnail == null || thumbnail.isEmpty
                    ? const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                      )
                    : CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title.isNotEmpty
                                    ? item.product.title
                                    : 'Product',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (attributes.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  attributes,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: isMutating ? null : onRemove,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.unitPrice}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Opacity(
                          opacity: isMutating ? 0.5 : 1,
                          child: QuantityStepper(
                            value: item.quantity,
                            onIncrement: isMutating ? () {} : onIncrement,
                            onDecrement: isMutating ? () {} : onDecrement,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.totalPrice,
    required this.hasItems,
    required this.onCheckout,
  });

  final num totalPrice;
  final bool hasItems;
  final VoidCallback onCheckout;

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
                  'Total Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              height: 44,
              child: ElevatedButton(
                onPressed: hasItems ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

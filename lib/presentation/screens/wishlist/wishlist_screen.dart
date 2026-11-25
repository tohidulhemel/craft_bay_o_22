import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../state/nav_state.dart';
import '../../state/wishlist_state.dart';
import '../../widgets/product_card.dart';
import '../products/product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistState>().loadWishlist();
    });
  }

  Future<void> _removeItem(String wishlistId) async {
    final ok = await context.read<WishlistState>().removeItem(wishlistId);
    if (!mounted) return;
    if (ok) {
      SnackbarUtils.show(context, 'Removed from wish list.');
    } else {
      final msg = context.read<WishlistState>().errorMessage ??
          'Could not remove item.';
      SnackbarUtils.show(context, msg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WishlistState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.read<NavState>().goHome(),
        ),
        title: const Text(
          'Wish List',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<WishlistState>().loadWishlist(force: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(WishlistState state) {
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
              onPressed: () => state.loadWishlist(force: true),
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
              'Your wish list is empty.',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ProductCard(
          product: item.product,
          isWishlisted: true,
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
          onWishlistTap: () => _removeItem(item.id),
        );
      },
    );
  }
}

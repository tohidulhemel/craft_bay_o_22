import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../domain/repositories/catalog_repository.dart';
import '../../state/product_list_state.dart';
import '../../state/wishlist_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/wishlist_toggle_helper.dart';
import 'product_details_screen.dart';

class ProductListArgs {
  const ProductListArgs({
    required this.title,
    this.categoryId,
    this.tag,
    this.searchQuery,
  });

  final String title;
  final String? categoryId;
  final String? tag;
  final String? searchQuery;
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key, required this.args});

  final ProductListArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductListState(
        context.read<CatalogRepository>(),
        categoryId: args.categoryId,
        tag: args.tag,
        searchQuery: args.searchQuery,
      )..loadInitial(),
      child: _ProductListView(title: args.title),
    );
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView({required this.title});

  final String title;

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ProductListState>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductListState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductListState>().loadInitial(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(ProductListState state) {
    if (state.isLoading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.products.isEmpty) {
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
              onPressed: state.loadInitial,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (state.products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'No products found.',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = state.products[index];
                final isWishlisted =
                    context.watch<WishlistState>().isWishlisted(product.id);
                return ProductCard(
                  product: product,
                  isWishlisted: isWishlisted,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.productDetails,
                    arguments: ProductDetailsArgs(
                      productId: product.id,
                      initialProduct: product,
                    ),
                  ),
                  onWishlistTap: () =>
                      toggleWishlistWithFeedback(context, product),
                );
              },
              childCount: state.products.length,
            ),
          ),
        ),
        if (state.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../app/app_assets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/banner_slide.dart';
import '../../../domain/models/product.dart';
import '../../state/home_state.dart';
import '../../state/nav_state.dart';
import '../../state/wishlist_state.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/wishlist_toggle_helper.dart';
import '../products/product_details_screen.dart';
import '../products/product_list_screen.dart';
import 'widgets/home_banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeState>().loadHome();
      if (AppDependencies.authStorage.isLoggedIn) {
        context.read<WishlistState>().loadWishlist();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(
      context,
      AppRoutes.productList,
      arguments: ProductListArgs(
        title: 'Search: $query',
        searchQuery: query,
      ),
    );
  }

  void _openCategoryProducts(String title, String categoryId) {
    Navigator.pushNamed(
      context,
      AppRoutes.productList,
      arguments: ProductListArgs(title: title, categoryId: categoryId),
    );
  }

  void _onBannerBuyNow(BannerSlide slide) {
    if (slide.productId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.productDetails,
        arguments: ProductDetailsArgs(productId: slide.productId!),
      );
      return;
    }
    if (slide.categoryId != null) {
      _openCategoryProducts('Featured', slide.categoryId!);
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.productList,
      arguments: const ProductListArgs(title: 'Featured Products'),
    );
  }

  void _onProductTap(Product product) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(
        productId: product.id,
        initialProduct: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppConstants.screenPadding,
        title: SvgPicture.asset(AppAssets.logoNav, height: 26),
        actions: [
          _CircleIconButton(
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.call_outlined,
            onTap: () => SnackbarUtils.show(
              context,
              'Customer support is available 9 AM - 9 PM.',
            ),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.notifications_none_outlined,
            onTap: () => SnackbarUtils.show(context, 'No new notifications.'),
          ),
          const SizedBox(width: AppConstants.screenPadding),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeState>().loadHome(force: true),
        child: _buildBody(home),
      ),
    );
  }

  Widget _buildBody(HomeState home) {
    if (home.isLoading && home.categories.isEmpty && home.slides.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (home.errorMessage != null &&
        home.categories.isEmpty &&
        home.slides.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(
            home.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => home.loadHome(force: true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPadding,
        8,
        AppConstants.screenPadding,
        24,
      ),
      children: [
        _SearchField(
          controller: _searchController,
          onSubmitted: _onSearchSubmitted,
        ),
        const SizedBox(height: 16),
        HomeBannerCarousel(
          slides: home.slides,
          onBuyNow: _onBannerBuyNow,
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'All Categories',
          onSeeAll: () => context.read<NavState>().goTo(NavState.categories),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 98,
          child: home.categories.isEmpty
              ? const Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: home.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final category = home.categories[index];
                    return CategoryCard(
                      category: category,
                      onTap: () => _openCategoryProducts(
                        category.title,
                        category.id,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 14),
        _ProductSection(
          title: 'Popular',
          products: home.popularProducts,
          onSeeAll: () =>
              _openCategoryProducts('Popular', home.popularCategoryId),
          onProductTap: _onProductTap,
        ),
        const SizedBox(height: 18),
        _ProductSection(
          title: 'Special',
          products: home.specialProducts,
          onSeeAll: () =>
              _openCategoryProducts('Special', home.specialCategoryId),
          onProductTap: _onProductTap,
        ),
        const SizedBox(height: 18),
        _ProductSection(
          title: 'New',
          products: home.newProducts,
          onSeeAll: () =>
              _openCategoryProducts('New', home.newCategoryId),
          onProductTap: _onProductTap,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19, color: AppColors.textDark),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: const InputDecoration(
        hintText: 'Search',
        filled: true,
        fillColor: Color(0xFFF3F4F6),
        prefixIcon: Icon(Icons.search, color: AppColors.textGrey, size: 22),
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    required this.onSeeAll,
    required this.onProductTap,
  });

  final String title;
  final List<Product> products;
  final VoidCallback onSeeAll;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: products.isEmpty
              ? const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isWishlisted =
                        context.watch<WishlistState>().isWishlisted(product.id);
                    return ProductCard(
                      width: 130,
                      product: product,
                      isWishlisted: isWishlisted,
                      onTap: () => onProductTap(product),
                      onWishlistTap: () =>
                          toggleWishlistWithFeedback(context, product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

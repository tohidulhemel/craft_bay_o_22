import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../state/category_state.dart';
import '../../state/nav_state.dart';
import '../../widgets/category_card.dart';
import '../products/product_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryState>().loadInitial();
    });
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
      context.read<CategoryState>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoryState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.read<NavState>().goHome(),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<CategoryState>().loadInitial(force: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(CategoryState state) {
    if (state.isLoading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.categories.isEmpty) {
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
              onPressed: () => state.loadInitial(force: true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (state.categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'No categories found.',
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
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = state.categories[index];
                return CategoryCard(
                  category: category,
                  boxSize: 64,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.productList,
                    arguments: ProductListArgs(
                      title: category.title,
                      categoryId: category.id,
                    ),
                  ),
                );
              },
              childCount: state.categories.length,
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../domain/models/review.dart';
import '../../../domain/repositories/catalog_repository.dart';
import '../../state/review_state.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewState(
        context.read<CatalogRepository>(),
        productId: productId,
      )..loadInitial(),
      child: _ReviewsView(productId: productId),
    );
  }
}

class _ReviewsView extends StatefulWidget {
  const _ReviewsView({required this.productId});

  final String productId;

  @override
  State<_ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<_ReviewsView> {
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
      context.read<ReviewState>().loadMore();
    }
  }

  Future<void> _openCreateReview() async {
    final created = await Navigator.pushNamed(
      context,
      AppRoutes.createReview,
      arguments: widget.productId,
    );
    if (created == true && mounted) {
      context.read<ReviewState>().loadInitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReviewState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reviews',
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
              onRefresh: () => context.read<ReviewState>().loadInitial(),
              child: _buildList(state),
            ),
          ),
          _ReviewsBottomBar(
            totalCount: state.totalCount,
            onAddTap: _openCreateReview,
          ),
        ],
      ),
    );
  }

  Widget _buildList(ReviewState state) {
    if (state.isLoading && state.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.reviews.isEmpty) {
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

    if (state.reviews.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'No reviews yet. Be the first to review!',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      itemCount: state.reviews.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= state.reviews.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _ReviewCard(review: state.reviews[index]);
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = review.avatarUrl;

    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFF3F4F6),
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.textGrey,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.userName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.star, size: 15, color: AppColors.star),
                const SizedBox(width: 3),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment.isNotEmpty ? review.comment : 'No comment.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsBottomBar extends StatelessWidget {
  const _ReviewsBottomBar({
    required this.totalCount,
    required this.onAddTap,
  });

  final int totalCount;
  final VoidCallback onAddTap;

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
            Text(
              'Reviews ($totalCount)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            FloatingActionButton.small(
              onPressed: onAddTap,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

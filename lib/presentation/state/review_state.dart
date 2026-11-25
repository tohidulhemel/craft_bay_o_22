import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/review.dart';
import '../../domain/repositories/catalog_repository.dart';

class ReviewState extends ChangeNotifier {
  ReviewState(this._repository, {required this.productId});

  final CatalogRepository _repository;
  final String productId;

  static const int _pageSize = 15;

  final List<Review> _reviews = [];
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSubmitting = false;
  int? _nextPage = 1;
  String? _errorMessage;

  List<Review> get reviews => List.unmodifiable(_reviews);
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSubmitting => _isSubmitting;
  bool get hasMore => _nextPage != null;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitial() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getReviews(
        productId: productId,
        page: 1,
        count: _pageSize,
      );
      _reviews
        ..clear()
        ..addAll(result.items);
      _totalCount = result.total;
      _nextPage = result.nextPage;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load reviews.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    final page = _nextPage;
    if (page == null || _isLoading || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getReviews(
        productId: productId,
        page: page,
        count: _pageSize,
      );
      _reviews.addAll(result.items);
      _totalCount = result.total;
      _nextPage = result.nextPage;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load more reviews.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required num rating,
    required String comment,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not submit review. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

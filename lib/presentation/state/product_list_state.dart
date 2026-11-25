import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/catalog_repository.dart';

class ProductListState extends ChangeNotifier {
  ProductListState(
    this._repository, {
    this.categoryId,
    this.tag,
    this.searchQuery,
  });

  final CatalogRepository _repository;
  final String? categoryId;
  final String? tag;
  final String? searchQuery;

  static const int _pageSize = 15;

  final List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int? _nextPage = 1;
  String? _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => !_isSearchMode && _nextPage != null;
  String? get errorMessage => _errorMessage;

  bool get _isSearchMode =>
      searchQuery != null && searchQuery!.trim().isNotEmpty;

  Future<void> loadInitial() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isSearchMode) {
        // The backend rejects search query parameters, so fetch a batch and filter locally.
        final result = await _repository.getProducts(page: 1, count: 100);
        final query = searchQuery!.trim().toLowerCase();
        final filtered = result.items.where((product) {
          final inTitle = product.title.toLowerCase().contains(query);
          final inDesc = product.description.toLowerCase().contains(query);
          final inBrand =
              product.brand?.title.toLowerCase().contains(query) ?? false;
          final inCat = product.categories
              .any((c) => c.title.toLowerCase().contains(query));
          return inTitle || inDesc || inBrand || inCat;
        }).toList();

        _products
          ..clear()
          ..addAll(filtered);
        _nextPage = null;
      } else {
        final result = await _repository.getProducts(
          page: 1,
          count: _pageSize,
          categoryId: categoryId,
          tag: tag,
        );
        _products
          ..clear()
          ..addAll(result.items);
        _nextPage = result.nextPage;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load products. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isSearchMode) return;
    final page = _nextPage;
    if (page == null || _isLoading || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getProducts(
        page: page,
        count: _pageSize,
        categoryId: categoryId,
        tag: tag,
      );
      _products.addAll(result.items);
      _nextPage = result.nextPage;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load more products.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}

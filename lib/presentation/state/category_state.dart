import 'package:flutter/foundation.dart' hide Category;

import '../../core/network/api_exception.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/catalog_repository.dart';

class CategoryState extends ChangeNotifier {
  CategoryState(this._repository);

  final CatalogRepository _repository;
  static const int _pageSize = 20;

  final List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoaded = false;
  int? _nextPage = 1;
  String? _errorMessage;

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _nextPage != null;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitial({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getCategories(page: 1, count: _pageSize);
      _categories
        ..clear()
        ..addAll(result.items);
      _nextPage = result.nextPage;
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load categories. Please try again.';
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
      final result = await _repository.getCategories(
        page: page,
        count: _pageSize,
      );
      _categories.addAll(result.items);
      _nextPage = result.nextPage;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load more categories.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}

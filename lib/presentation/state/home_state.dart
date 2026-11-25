import 'package:flutter/foundation.dart' hide Category;

import '../../core/network/api_exception.dart';
import '../../domain/models/banner_slide.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/catalog_repository.dart';

class HomeState extends ChangeNotifier {
  HomeState(this._repository);

  final CatalogRepository _repository;

  static const String _fallbackPopularId = '67c35af85e8a445235de197b';
  static const String _fallbackSpecialId = '67c35b395e8a445235de197e';
  static const String _fallbackNewId = '67c7bec4623a876bc4766fea';

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<BannerSlide> _slides = const [];
  List<Category> _categories = const [];
  List<Product> _popularProducts = const [];
  List<Product> _specialProducts = const [];
  List<Product> _newProducts = const [];

  String _popularCategoryId = _fallbackPopularId;
  String _specialCategoryId = _fallbackSpecialId;
  String _newCategoryId = _fallbackNewId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BannerSlide> get slides => _slides;
  List<Category> get categories => _categories;
  List<Product> get popularProducts => _popularProducts;
  List<Product> get specialProducts => _specialProducts;
  List<Product> get newProducts => _newProducts;

  String get popularCategoryId => _popularCategoryId;
  String get specialCategoryId => _specialCategoryId;
  String get newCategoryId => _newCategoryId;

  Future<void> loadHome({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final slidesFuture = _repository.getSlides();
      final categoriesFuture = _repository.getCategories(page: 1, count: 20);

      final slides = await slidesFuture;
      final categoryPage = await categoriesFuture;
      final categories = categoryPage.items;

      _popularCategoryId = _resolveCategoryId(
        categories,
        slugs: const ['popular'],
        fallback: _fallbackPopularId,
      );
      _specialCategoryId = _resolveCategoryId(
        categories,
        slugs: const ['special'],
        fallback: _fallbackSpecialId,
      );
      _newCategoryId = _resolveCategoryId(
        categories,
        slugs: const ['new-arr', 'new', 'new-arrival'],
        fallback: _fallbackNewId,
      );

      final sections = await Future.wait([
        _repository.getProducts(
          page: 1,
          count: 10,
          categoryId: _popularCategoryId,
        ),
        _repository.getProducts(
          page: 1,
          count: 10,
          categoryId: _specialCategoryId,
        ),
        _repository.getProducts(
          page: 1,
          count: 10,
          categoryId: _newCategoryId,
        ),
      ]);

      _slides = slides;
      _categories = categories;
      _popularProducts = sections[0].items;
      _specialProducts = sections[1].items;
      _newProducts = sections[2].items;
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load home data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _resolveCategoryId(
    List<Category> categories, {
    required List<String> slugs,
    required String fallback,
  }) {
    for (final category in categories) {
      final slug = category.slug.toLowerCase();
      final title = category.title.toLowerCase();
      if (slugs.contains(slug) || slugs.contains(title)) {
        return category.id;
      }
    }
    return fallback;
  }
}

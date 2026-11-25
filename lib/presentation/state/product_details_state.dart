import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/catalog_repository.dart';

class ProductDetailsState extends ChangeNotifier {
  ProductDetailsState(this._repository);

  final CatalogRepository _repository;

  Product? _product;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedColor => _selectedColor;
  String? get selectedSize => _selectedSize;
  int get quantity => _quantity;

  Future<void> loadProduct(String productId, {Product? initialProduct}) async {
    if (initialProduct != null) {
      _product = initialProduct;
      _initSelections(initialProduct);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.getProductById(productId);
      _product = fetched;
      _initSelections(fetched);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load product details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initSelections(Product product) {
    if (_selectedColor == null && product.colors.isNotEmpty) {
      _selectedColor = product.colors.first;
    }
    if (_selectedSize == null && product.sizes.isNotEmpty) {
      _selectedSize = product.sizes.first;
    }
  }

  void selectColor(String color) {
    if (_selectedColor == color) return;
    _selectedColor = color;
    notifyListeners();
  }

  void selectSize(String size) {
    if (_selectedSize == size) return;
    _selectedSize = size;
    notifyListeners();
  }

  void incrementQuantity() {
    if (_quantity >= 99) return;
    _quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (_quantity <= 1) return;
    _quantity--;
    notifyListeners();
  }
}

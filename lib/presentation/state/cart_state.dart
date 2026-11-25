import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartState extends ChangeNotifier {
  CartState(this._repository);

  final CartRepository _repository;

  final List<CartItem> _items = [];
  final Set<String> _mutatingItemIds = {};

  bool _isLoading = false;
  bool _isAdding = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  String? get errorMessage => _errorMessage;

  bool isItemMutating(String cartItemId) =>
      _mutatingItemIds.contains(cartItemId);

  num get totalPrice =>
      _items.fold<num>(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.getCartItems();
      _items
        ..clear()
        ..addAll(fetched);
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load cart items.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  }) async {
    if (_isAdding) return false;

    _isAdding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addToCart(
        productId: productId,
        quantity: quantity,
        color: color,
        size: size,
      );
      await loadCart(force: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not add item to cart.';
      return false;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    if (quantity < 1 || _mutatingItemIds.contains(cartItemId)) return false;

    _mutatingItemIds.add(cartItemId);
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not update quantity.';
      return false;
    } finally {
      _mutatingItemIds.remove(cartItemId);
      notifyListeners();
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    if (_mutatingItemIds.contains(cartItemId)) return false;

    _mutatingItemIds.add(cartItemId);
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.removeCartItem(cartItemId);
      _items.removeWhere((item) => item.id == cartItemId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not remove item from cart.';
      return false;
    } finally {
      _mutatingItemIds.remove(cartItemId);
      notifyListeners();
    }
  }

  void clearLocal() {
    _items.clear();
    _mutatingItemIds.clear();
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}

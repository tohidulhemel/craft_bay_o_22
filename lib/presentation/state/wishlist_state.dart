import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/product.dart';
import '../../domain/models/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

class WishlistState extends ChangeNotifier {
  WishlistState(this._repository);

  final WishlistRepository _repository;

  final List<WishlistItem> _items = [];
  final Set<String> _togglingProductIds = {};

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<WishlistItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isWishlisted(String productId) =>
      _items.any((item) => item.product.id == productId);

  bool isToggling(String productId) =>
      _togglingProductIds.contains(productId);

  Future<void> loadWishlist({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.getWishlist();
      _items
        ..clear()
        ..addAll(fetched);
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load wishlist.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns `true` if added, `false` if removed, or `null` if the call failed.
  Future<bool?> toggleWishlist(Product product) async {
    final productId = product.id;
    if (_togglingProductIds.contains(productId)) return null;

    _togglingProductIds.add(productId);
    _errorMessage = null;
    notifyListeners();

    try {
      final existingIndex =
          _items.indexWhere((item) => item.product.id == productId);
      if (existingIndex != -1) {
        final wishlistId = _items[existingIndex].id;
        await _repository.removeFromWishlist(wishlistId);
        _items.removeAt(existingIndex);
        return false;
      } else {
        await _repository.addToWishlist(productId);
        await loadWishlist(force: true);
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (_) {
      _errorMessage = 'Could not update wishlist.';
      return null;
    } finally {
      _togglingProductIds.remove(productId);
      notifyListeners();
    }
  }

  Future<bool> removeItem(String wishlistItemId) async {
    _errorMessage = null;
    try {
      await _repository.removeFromWishlist(wishlistItemId);
      _items.removeWhere((item) => item.id == wishlistItemId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not remove item from wishlist.';
      notifyListeners();
      return false;
    }
  }

  void clearLocal() {
    _items.clear();
    _togglingProductIds.clear();
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}

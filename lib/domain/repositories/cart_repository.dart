import '../models/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();

  Future<void> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  });

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<void> removeCartItem(String cartItemId);
}

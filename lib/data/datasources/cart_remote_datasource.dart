import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._client);

  final ApiClient _client;

  Future<dynamic> getCartItems() =>
      _client.get(ApiEndpoints.cart, query: const {'count': 100});

  Future<dynamic> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  }) {
    final body = <String, dynamic>{
      'product': productId,
      'quantity': quantity,
    };
    if (color != null && color.isNotEmpty) body['color'] = color;
    if (size != null && size.isNotEmpty) body['size'] = size;

    return _client.post(ApiEndpoints.cart, body: body);
  }

  Future<dynamic> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) {
    return _client.patch(
      ApiEndpoints.cartItem(cartItemId),
      body: {'quantity': quantity},
    );
  }

  Future<dynamic> removeCartItem(String cartItemId) =>
      _client.delete(ApiEndpoints.cartItem(cartItemId));
}

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class WishlistRemoteDataSource {
  WishlistRemoteDataSource(this._client);

  final ApiClient _client;

  Future<dynamic> getWishlist() =>
      _client.get(ApiEndpoints.wishlist, query: const {'count': 100});

  Future<dynamic> addToWishlist(String productId) =>
      _client.post(ApiEndpoints.wishlist, body: {'product': productId});

  Future<dynamic> removeFromWishlist(String wishlistItemId) =>
      _client.delete(ApiEndpoints.wishlistItem(wishlistItemId));
}

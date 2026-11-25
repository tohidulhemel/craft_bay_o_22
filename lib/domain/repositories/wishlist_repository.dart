import '../models/wishlist_item.dart';

abstract class WishlistRepository {
  Future<List<WishlistItem>> getWishlist();

  Future<void> addToWishlist(String productId);

  Future<void> removeFromWishlist(String wishlistItemId);
}

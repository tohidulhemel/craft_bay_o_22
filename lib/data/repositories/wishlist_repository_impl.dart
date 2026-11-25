import '../../domain/models/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';
import '../mappers/catalog_json_parser.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._remote);

  final WishlistRemoteDataSource _remote;

  @override
  Future<List<WishlistItem>> getWishlist() async {
    final body = await _remote.getWishlist();
    return CatalogJsonParser.parseEnvelopeList(body, _parseWishlistItem);
  }

  @override
  Future<void> addToWishlist(String productId) async {
    await _remote.addToWishlist(productId);
  }

  @override
  Future<void> removeFromWishlist(String wishlistItemId) async {
    await _remote.removeFromWishlist(wishlistItemId);
  }

  WishlistItem _parseWishlistItem(Map<String, dynamic> json) {
    final productJson = CatalogJsonParser.asMap(json['product']);
    return WishlistItem(
      id: CatalogJsonParser.asString(json['_id']),
      product: CatalogJsonParser.parseProduct(productJson),
    );
  }
}

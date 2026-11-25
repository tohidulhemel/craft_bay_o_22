import '../../domain/models/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../mappers/catalog_json_parser.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remote);

  final CartRemoteDataSource _remote;

  @override
  Future<List<CartItem>> getCartItems() async {
    final body = await _remote.getCartItems();
    return CatalogJsonParser.parseEnvelopeList(body, _parseCartItem);
  }

  @override
  Future<void> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  }) async {
    await _remote.addToCart(
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
    );
  }

  @override
  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    await _remote.updateQuantity(cartItemId: cartItemId, quantity: quantity);
  }

  @override
  Future<void> removeCartItem(String cartItemId) async {
    await _remote.removeCartItem(cartItemId);
  }

  CartItem _parseCartItem(Map<String, dynamic> json) {
    final productJson = CatalogJsonParser.asMap(json['product']);
    return CartItem(
      id: CatalogJsonParser.asString(json['_id']),
      product: CatalogJsonParser.parseProduct(productJson),
      quantity: (CatalogJsonParser.asInt(json['quantity']) ?? 1).clamp(1, 99),
      color: CatalogJsonParser.asNullableString(json['color']),
      size: CatalogJsonParser.asNullableString(json['size']),
    );
  }
}

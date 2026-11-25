import 'package:craft_bay_app/core/network/api_client.dart';
import 'package:craft_bay_app/core/storage/auth_storage.dart';
import 'package:craft_bay_app/data/datasources/cart_remote_datasource.dart';
import 'package:craft_bay_app/data/datasources/wishlist_remote_datasource.dart';
import 'package:craft_bay_app/data/repositories/cart_repository_impl.dart';
import 'package:craft_bay_app/data/repositories/wishlist_repository_impl.dart';
import 'package:craft_bay_app/domain/models/product.dart';
import 'package:craft_bay_app/presentation/state/cart_state.dart';
import 'package:craft_bay_app/presentation/state/wishlist_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCartRemoteDataSource extends CartRemoteDataSource {
  _FakeCartRemoteDataSource() : super(ApiClient(AuthStorage()));

  final List<Map<String, dynamic>> items = [
    {
      '_id': 'cart1',
      'quantity': 2,
      'color': 'Red',
      'size': 'XL',
      'product': {
        '_id': 'p1',
        'title': 'New Year Special Shoe',
        'slug': 'shoe',
        'description': 'Running shoe',
        'photos': ['https://example.com/shoe.png'],
        'colors': ['Red'],
        'sizes': ['XL'],
        'tags': [],
        'current_price': 100,
        'quantity': 5,
        'categories': [],
      },
    },
  ];

  @override
  Future<dynamic> getCartItems() async => {
        'code': 200,
        'status': 'success',
        'data': {'results': List<Map<String, dynamic>>.from(items)},
      };

  @override
  Future<dynamic> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  }) async {
    items.add({
      '_id': 'cart${items.length + 1}',
      'quantity': quantity,
      'color': color,
      'size': size,
      'product': {
        '_id': productId,
        'title': 'Added Product',
        'slug': 'added',
        'description': '',
        'photos': <String>[],
        'colors': <String>[],
        'sizes': <String>[],
        'tags': <String>[],
        'current_price': 50,
        'quantity': 2,
        'categories': <dynamic>[],
      },
    });
    return {'code': 200, 'status': 'success'};
  }

  @override
  Future<dynamic> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final idx = items.indexWhere((e) => e['_id'] == cartItemId);
    if (idx != -1) items[idx]['quantity'] = quantity;
    return {'code': 200, 'status': 'success'};
  }

  @override
  Future<dynamic> removeCartItem(String cartItemId) async {
    items.removeWhere((e) => e['_id'] == cartItemId);
    return {'code': 200, 'status': 'success'};
  }
}

class _FakeWishlistRemoteDataSource extends WishlistRemoteDataSource {
  _FakeWishlistRemoteDataSource() : super(ApiClient(AuthStorage()));

  final List<Map<String, dynamic>> items = [];

  @override
  Future<dynamic> getWishlist() async => {
        'code': 200,
        'status': 'success',
        'data': {'results': List<Map<String, dynamic>>.from(items)},
      };

  @override
  Future<dynamic> addToWishlist(String productId) async {
    items.add({
      '_id': 'w1',
      'product': {
        '_id': productId,
        'title': 'New Year Special Shoe',
        'slug': 'shoe',
        'description': '',
        'photos': <String>[],
        'colors': <String>[],
        'sizes': <String>[],
        'tags': <String>[],
        'current_price': 100,
        'quantity': 1,
        'categories': <dynamic>[],
      },
    });
    return {'code': 200, 'status': 'success'};
  }

  @override
  Future<dynamic> removeFromWishlist(String wishlistItemId) async {
    items.removeWhere((e) => e['_id'] == wishlistItemId);
    return {'code': 200, 'status': 'success'};
  }
}

void main() {
  test('CartState loads, updates quantity, adds, and removes items', () async {
    final state = CartState(CartRepositoryImpl(_FakeCartRemoteDataSource()));

    await state.loadCart();
    expect(state.items, hasLength(1));
    expect(state.totalPrice, 200);

    final updated = await state.updateQuantity('cart1', 3);
    expect(updated, isTrue);
    expect(state.items.first.quantity, 3);
    expect(state.totalPrice, 300);

    final added = await state.addToCart(productId: 'p2', quantity: 2);
    expect(added, isTrue);
    expect(state.items, hasLength(2));
    expect(state.totalPrice, 400);

    final removed = await state.removeItem('cart1');
    expect(removed, isTrue);
    expect(state.items, hasLength(1));
    expect(state.totalPrice, 100);
  });

  test('WishlistState toggles product add and remove', () async {
    final state = WishlistState(
      WishlistRepositoryImpl(_FakeWishlistRemoteDataSource()),
    );
    const product = Product(
      id: 'p1',
      title: 'New Year Special Shoe',
      slug: 'shoe',
      description: '',
      photos: [],
      colors: [],
      sizes: [],
      tags: [],
      currentPrice: 100,
      quantity: 1,
      categories: [],
    );

    await state.loadWishlist();
    expect(state.isWishlisted('p1'), isFalse);

    final added = await state.toggleWishlist(product);
    expect(added, isTrue);
    expect(state.isWishlisted('p1'), isTrue);

    final removed = await state.toggleWishlist(product);
    expect(removed, isFalse);
    expect(state.isWishlisted('p1'), isFalse);
  });
}

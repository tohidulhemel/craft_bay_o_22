import 'package:craft_bay_app/core/network/api_client.dart';
import 'package:craft_bay_app/core/storage/auth_storage.dart';
import 'package:craft_bay_app/data/datasources/catalog_remote_datasource.dart';
import 'package:craft_bay_app/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRemoteDataSource extends CatalogRemoteDataSource {
  _FakeCatalogRemoteDataSource() : super(ApiClient(AuthStorage()));

  @override
  Future<dynamic> getSlides() async => {
        'code': 200,
        'status': 'success',
        'data': {
          'results': [
            {
              '_id': 's1',
              'photo_url': 'https://example.com/slide.png',
              'description': 'Happy New Year Special Deal',
              'product': null,
              'brand': 'b1',
              'category': 'c1',
            },
          ],
          'total': 1,
          'next': null,
          'last_page': 1,
        },
      };

  @override
  Future<dynamic> getCategories({int page = 1, int count = 20}) async => {
        'code': 200,
        'status': 'success',
        'data': {
          'results': [
            {
              '_id': 'c1',
              'title': 'Electronics',
              'slug': 'electronics',
              'description': 'Gadgets',
              'icon': 'https://example.com/icon.png',
              'parent': null,
            },
          ],
          'total': 10,
          'next': 2,
          'last_page': 5,
        },
      };

  @override
  Future<dynamic> getProducts({
    int page = 1,
    int count = 10,
    String? categoryId,
    String? tag,
  }) async =>
      {
        'code': 200,
        'status': 'success',
        'data': {
          'results': [
            {
              '_id': 'p1',
              'title': 'New Year Special Shoe',
              'slug': 'special-shoe',
              'description': 'Comfortable running shoe',
              'photos': ['https://example.com/shoe.png'],
              'colors': ['Red', 'Blue'],
              'sizes': ['XL', '2L'],
              'tags': ['popular'],
              'current_price': 100,
              'regular_price': 150,
              'quantity': 5,
              'brand': {
                '_id': 'b1',
                'title': 'Nike',
                'slug': 'nike',
                'icon': '',
              },
              'categories': [
                {
                  '_id': 'c1',
                  'title': 'Electronics',
                  'slug': 'electronics',
                  'icon': '',
                },
              ],
            },
          ],
          'total': 1,
          'next': null,
          'last_page': 1,
        },
      };

  @override
  Future<dynamic> getProductById(String id) async => {
        'code': 200,
        'status': 'success',
        'data': {
          '_id': id,
          'title': 'New Year Special Shoe',
          'slug': 'special-shoe',
          'description': 'Comfortable running shoe',
          'photos': ['https://example.com/shoe.png'],
          'colors': ['Black', 'Red'],
          'sizes': ['X', 'XL'],
          'tags': ['popular'],
          'current_price': 1000,
          'regular_price': 1200,
          'quantity': 3,
          'categories': [],
        },
      };

  @override
  Future<dynamic> getReviews({
    required String productId,
    int page = 1,
    int count = 10,
  }) async =>
      {
        'code': 200,
        'status': 'success',
        'data': {
          'results': [
            {
              '_id': 'r1',
              'product': {'_id': productId},
              'user': {
                '_id': 'u1',
                'first_name': 'Rabbil',
                'last_name': 'Hasan',
                'avatar_url': null,
              },
              'rating': 4.5,
              'comment': 'Great shoe!',
              'createdAt': '2026-09-05T19:54:28.576Z',
            },
          ],
          'total': 1,
          'next': null,
          'last_page': 1,
        },
      };

  String? lastCreatedComment;
  num? lastCreatedRating;

  @override
  Future<dynamic> createReview({
    required String productId,
    required num rating,
    required String comment,
  }) async {
    lastCreatedRating = rating;
    lastCreatedComment = comment;
    return {'code': 200, 'status': 'success'};
  }
}

void main() {
  late _FakeCatalogRemoteDataSource fakeRemote;
  late CatalogRepositoryImpl repository;

  setUp(() {
    fakeRemote = _FakeCatalogRemoteDataSource();
    repository = CatalogRepositoryImpl(fakeRemote);
  });

  test('parses slides from API envelope', () async {
    final slides = await repository.getSlides();
    expect(slides, hasLength(1));
    expect(slides.first.id, 's1');
    expect(slides.first.description, 'Happy New Year Special Deal');
    expect(slides.first.categoryId, 'c1');
  });

  test('parses paginated categories', () async {
    final result = await repository.getCategories(page: 1, count: 20);
    expect(result.items, hasLength(1));
    expect(result.items.first.title, 'Electronics');
    expect(result.hasMore, isTrue);
    expect(result.nextPage, 2);
  });

  test('parses paginated products with brand and categories', () async {
    final result = await repository.getProducts();
    expect(result.items, hasLength(1));
    final product = result.items.first;
    expect(product.title, 'New Year Special Shoe');
    expect(product.currentPrice, 100);
    expect(product.brand?.title, 'Nike');
    expect(product.categories.first.id, 'c1');
    expect(result.hasMore, isFalse);
  });

  test('parses single product details by id', () async {
    final product = await repository.getProductById('p1');
    expect(product.id, 'p1');
    expect(product.currentPrice, 1000);
    expect(product.colors, ['Black', 'Red']);
    expect(product.sizes, ['X', 'XL']);
  });

  test('parses paginated reviews and submits review', () async {
    final reviews = await repository.getReviews(productId: 'p1');
    expect(reviews.items, hasLength(1));
    expect(reviews.items.first.userName, 'Rabbil Hasan');
    expect(reviews.items.first.rating, 4.5);
    expect(reviews.items.first.comment, 'Great shoe!');

    await repository.createReview(
      productId: 'p1',
      rating: 5,
      comment: 'Awesome quality',
    );
    expect(fakeRemote.lastCreatedRating, 5);
    expect(fakeRemote.lastCreatedComment, 'Awesome quality');
  });
}

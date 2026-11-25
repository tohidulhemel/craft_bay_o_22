import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._client);

  final ApiClient _client;

  Future<dynamic> getSlides() => _client.get(ApiEndpoints.slides);

  Future<dynamic> getCategories({int page = 1, int count = 20}) {
    return _client.get(
      ApiEndpoints.categories,
      query: {'page': page, 'count': count},
    );
  }

  Future<dynamic> getProducts({
    int page = 1,
    int count = 10,
    String? categoryId,
    String? tag,
  }) {
    return _client.get(
      ApiEndpoints.products,
      query: {
        'page': page,
        'count': count,
        'category': categoryId,
        'tag': tag,
      },
    );
  }

  Future<dynamic> getProductById(String id) =>
      _client.get(ApiEndpoints.productById(id));

  Future<dynamic> getReviews({
    required String productId,
    int page = 1,
    int count = 10,
  }) {
    return _client.get(
      ApiEndpoints.reviews,
      query: {
        'product': productId,
        'page': page,
        'count': count,
      },
    );
  }

  Future<dynamic> createReview({
    required String productId,
    required num rating,
    required String comment,
  }) {
    return _client.post(
      ApiEndpoints.createReview,
      body: {
        'product': productId,
        'rating': rating,
        'comment': comment,
      },
    );
  }
}

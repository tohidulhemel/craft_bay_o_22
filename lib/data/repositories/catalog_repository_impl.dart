import '../../domain/models/banner_slide.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';
import '../mappers/catalog_json_parser.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<List<BannerSlide>> getSlides() async {
    final body = await _remote.getSlides();
    return CatalogJsonParser.parsePaginated(
      body,
      CatalogJsonParser.parseSlide,
    ).items;
  }

  @override
  Future<PaginatedResult<Category>> getCategories({
    int page = 1,
    int count = 20,
  }) async {
    final body = await _remote.getCategories(page: page, count: count);
    return CatalogJsonParser.parsePaginated(
      body,
      CatalogJsonParser.parseCategory,
    );
  }

  @override
  Future<PaginatedResult<Product>> getProducts({
    int page = 1,
    int count = 10,
    String? categoryId,
    String? tag,
  }) async {
    final body = await _remote.getProducts(
      page: page,
      count: count,
      categoryId: categoryId,
      tag: tag,
    );
    return CatalogJsonParser.parsePaginated(
      body,
      CatalogJsonParser.parseProduct,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    final body = await _remote.getProductById(id);
    final data = CatalogJsonParser.asMap(CatalogJsonParser.asMap(body)['data']);
    return CatalogJsonParser.parseProduct(data);
  }

  @override
  Future<PaginatedResult<Review>> getReviews({
    required String productId,
    int page = 1,
    int count = 10,
  }) async {
    final body = await _remote.getReviews(
      productId: productId,
      page: page,
      count: count,
    );
    return CatalogJsonParser.parsePaginated(
      body,
      CatalogJsonParser.parseReview,
    );
  }

  @override
  Future<void> createReview({
    required String productId,
    required num rating,
    required String comment,
  }) async {
    await _remote.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}

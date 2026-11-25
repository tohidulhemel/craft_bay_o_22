import '../models/banner_slide.dart';
import '../models/category.dart';
import '../models/paginated_result.dart';
import '../models/product.dart';
import '../models/review.dart';

abstract class CatalogRepository {
  Future<List<BannerSlide>> getSlides();

  Future<PaginatedResult<Category>> getCategories({
    int page = 1,
    int count = 20,
  });

  Future<PaginatedResult<Product>> getProducts({
    int page = 1,
    int count = 10,
    String? categoryId,
    String? tag,
  });

  Future<Product> getProductById(String id);

  Future<PaginatedResult<Review>> getReviews({
    required String productId,
    int page = 1,
    int count = 10,
  });

  Future<void> createReview({
    required String productId,
    required num rating,
    required String comment,
  });
}

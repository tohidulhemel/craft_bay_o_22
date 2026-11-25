import '../../domain/models/banner_slide.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/review.dart';

class CatalogJsonParser {
  CatalogJsonParser._();

  static PaginatedResult<T> parsePaginated<T>(
    dynamic body,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final data = asMap(asMap(body)['data']);
    final items = mapList(data['results'], mapper);
    return PaginatedResult<T>(
      items: items,
      total: asInt(data['total']) ?? items.length,
      nextPage: asInt(data['next']),
      lastPage: asInt(data['last_page']),
    );
  }

  /// Extracts a list of maps whether the envelope places it under
  /// `data.results` (paginated) or directly under `data`.
  static List<T> parseEnvelopeList<T>(
    dynamic body,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final data = asMap(body)['data'];
    if (data is List) {
      return mapList(data, mapper);
    }
    if (data is Map) {
      return mapList(asMap(data)['results'], mapper);
    }
    return const [];
  }

  static List<T> mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (raw is! List) return const [];
    final items = <T>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        items.add(mapper(entry));
      } else if (entry is Map) {
        items.add(mapper(Map<String, dynamic>.from(entry)));
      }
    }
    return items;
  }

  static BannerSlide parseSlide(Map<String, dynamic> json) {
    return BannerSlide(
      id: asString(json['_id']),
      photoUrl: asString(json['photo_url']),
      description: asString(json['description']),
      productId: extractId(json['product']),
      brandId: extractId(json['brand']),
      categoryId: extractId(json['category']),
    );
  }

  static Category parseCategory(Map<String, dynamic> json) {
    return Category(
      id: asString(json['_id']),
      title: asString(json['title']),
      slug: asString(json['slug']),
      description: asString(json['description']),
      icon: asString(json['icon']),
      parentId: extractId(json['parent']),
    );
  }

  static Review parseReview(Map<String, dynamic> json) {
    final user = asMap(json['user']);
    final first = asString(user['first_name']);
    final last = asString(user['last_name']);
    final fullName = '$first $last'.trim();
    final avatar = asString(user['avatar_url']);

    return Review(
      id: asString(json['_id']),
      productId: extractId(json['product']) ?? '',
      userName: fullName.isEmpty ? 'Anonymous' : fullName,
      avatarUrl: avatar.isEmpty ? null : avatar,
      rating: (asNum(json['rating']) ?? 5).toDouble(),
      comment: asString(json['comment']),
      createdAt: DateTime.tryParse(asString(json['createdAt'])),
    );
  }

  static Product parseProduct(Map<String, dynamic> json) {
    final rawBrand = json['brand'];
    ProductBrand? brand;
    if (rawBrand is Map) {
      final map = Map<String, dynamic>.from(rawBrand);
      brand = ProductBrand(
        id: asString(map['_id']),
        title: asString(map['title']),
        slug: asString(map['slug']),
        icon: asString(map['icon']),
      );
    }

    return Product(
      id: asString(json['_id']),
      title: asString(json['title']),
      slug: asString(json['slug']),
      description: asString(json['description']),
      photos: asStringList(json['photos']),
      colors: asStringList(json['colors']),
      sizes: asStringList(json['sizes']),
      tags: asStringList(json['tags']),
      currentPrice: asNum(json['current_price']) ?? 0,
      regularPrice: asNum(json['regular_price']),
      quantity: asInt(json['quantity']) ?? 0,
      brand: brand,
      categories: mapList(json['categories'], parseCategory),
    );
  }

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static String asString(dynamic value) => value?.toString().trim() ?? '';

  static String? asNullableString(dynamic value) {
    final text = asString(value);
    return text.isEmpty ? null : text;
  }

  static String? extractId(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return asNullableString(value['_id']);
    }
    return asNullableString(value);
  }

  static int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? asNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  static List<String> asStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

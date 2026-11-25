import 'category.dart';

class ProductBrand {
  const ProductBrand({
    required this.id,
    required this.title,
    required this.slug,
    required this.icon,
  });

  final String id;
  final String title;
  final String slug;
  final String icon;
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.photos,
    required this.colors,
    required this.sizes,
    required this.tags,
    required this.currentPrice,
    this.regularPrice,
    required this.quantity,
    this.brand,
    required this.categories,
    this.rating = 4.8,
  });

  final String id;
  final String title;
  final String slug;
  final String description;
  final List<String> photos;
  final List<String> colors;
  final List<String> sizes;
  final List<String> tags;
  final num currentPrice;
  final num? regularPrice;
  final int quantity;
  final ProductBrand? brand;
  final List<Category> categories;
  final double rating;

  String? get thumbnail => photos.isNotEmpty ? photos.first : null;
}

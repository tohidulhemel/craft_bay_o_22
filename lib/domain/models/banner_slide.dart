class BannerSlide {
  const BannerSlide({
    required this.id,
    required this.photoUrl,
    required this.description,
    this.productId,
    this.brandId,
    this.categoryId,
  });

  final String id;
  final String photoUrl;
  final String description;
  final String? productId;
  final String? brandId;
  final String? categoryId;
}

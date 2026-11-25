class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.userName,
    this.avatarUrl,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String userName;
  final String? avatarUrl;
  final double rating;
  final String comment;
  final DateTime? createdAt;
}

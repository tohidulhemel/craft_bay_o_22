class Category {
  const Category({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.icon,
    this.parentId,
  });

  final String id;
  final String title;
  final String slug;
  final String description;
  final String icon;
  final String? parentId;
}

class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.total,
    required this.nextPage,
    required this.lastPage,
  });

  final List<T> items;
  final int total;
  final int? nextPage;
  final int? lastPage;

  bool get hasMore => nextPage != null;
}

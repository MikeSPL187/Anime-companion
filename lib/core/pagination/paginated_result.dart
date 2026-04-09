class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.hasNextPage,
  });

  final List<T> items;
  final int page;
  final bool hasNextPage;
}

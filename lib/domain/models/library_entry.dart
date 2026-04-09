import '../enums/enums.dart';

class LibraryEntry {
  const LibraryEntry({
    required this.animeId,
    required this.status,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.lastInteractedAt,
    this.note,
  });

  final String animeId;
  final LibraryStatus status;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastInteractedAt;
  final String? note;
}

import '../enums/enums.dart';
import 'anime_summary.dart';

class LibraryPresentationSnapshot {
  const LibraryPresentationSnapshot({
    required this.animeId,
    required this.title,
    required this.snapshotSavedAt,
    this.altTitle,
    this.posterUrl,
    this.type,
    this.year,
    this.episodesTotal,
    this.favoritesCount,
  });

  factory LibraryPresentationSnapshot.fromAnimeSummary(
    AnimeSummary summary, {
    DateTime? savedAt,
  }) {
    return LibraryPresentationSnapshot(
      animeId: summary.id,
      title: summary.title,
      altTitle: _nonEmptyOrNull(summary.altTitle),
      posterUrl: _nonEmptyOrNull(summary.posterUrl),
      type: summary.type,
      year: summary.year,
      episodesTotal: summary.episodesTotal,
      favoritesCount: summary.favoritesCount,
      snapshotSavedAt: savedAt ?? DateTime.now(),
    );
  }

  final String animeId;
  final String title;
  final String? altTitle;
  final String? posterUrl;
  final AnimeType? type;
  final int? year;
  final int? episodesTotal;
  final int? favoritesCount;
  final DateTime snapshotSavedAt;
}

String? _nonEmptyOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

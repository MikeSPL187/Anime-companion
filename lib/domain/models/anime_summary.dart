import '../enums/enums.dart';

class AnimeSummary {
  const AnimeSummary({
    required this.id,
    required this.alias,
    required this.title,
    required this.posterUrl,
    required this.type,
    required this.isOngoing,
    required this.favoritesCount,
    this.altTitle,
    this.year,
    this.season,
    this.publishDay,
    this.ageRating,
    this.episodesTotal,
    this.episodesAired,
    this.updatedAt,
  });

  final String id;
  final String alias;
  final String title;
  final String? altTitle;
  final String posterUrl;
  final AnimeType type;
  final int? year;
  final AnimeSeason? season;
  final bool isOngoing;
  final PublishDay? publishDay;
  final AgeRating? ageRating;
  final int favoritesCount;
  final int? episodesTotal;
  final int? episodesAired;
  final DateTime? updatedAt;
}

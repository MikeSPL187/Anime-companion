class WatchProgress {
  const WatchProgress({
    required this.animeId,
    required this.watchedEpisodes,
    required this.updatedAt,
    this.lastWatchedEpisode,
  });

  final String animeId;
  final int watchedEpisodes;
  final int? lastWatchedEpisode;
  final DateTime updatedAt;
}

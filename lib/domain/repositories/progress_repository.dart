import '../models/watch_progress.dart';

abstract interface class ProgressRepository {
  Future<WatchProgress?> getProgress(String animeId);

  Stream<WatchProgress?> watchProgress(String animeId);

  Future<void> incrementEpisode(String animeId, {int? episodesTotal});

  Future<void> setEpisode(String animeId, int episode, {int? episodesTotal});

  Future<void> clearProgress(String animeId);
}

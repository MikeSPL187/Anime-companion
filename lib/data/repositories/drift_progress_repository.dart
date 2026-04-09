import 'package:drift/drift.dart';

import '../../core/database/app_database.dart' as db;
import '../../domain/enums/enums.dart';
import '../../domain/models/watch_progress.dart' as domain;
import '../../domain/repositories/progress_repository.dart';

class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<domain.WatchProgress?> getProgress(String animeId) async {
    final row = await _findProgress(animeId);
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<domain.WatchProgress?> watchProgress(String animeId) {
    final query = _database.select(_database.watchProgressEntries)
      ..where((table) => table.animeId.equals(animeId));

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toDomain(row),
    );
  }

  @override
  Future<void> incrementEpisode(String animeId, {int? episodesTotal}) {
    _validateEpisodesTotal(episodesTotal);

    return _database.transaction(() async {
      final libraryEntry = await _requireLibraryEntry(animeId);
      final current = await _findProgress(animeId);
      final nextEpisode = (current?.watchedEpisodes ?? 0) + 1;
      final status = LibraryStatus.values.byName(libraryEntry.status);

      _validateEpisode(
        nextEpisode,
        episodesTotal: episodesTotal,
        libraryStatus: status,
      );

      final now = DateTime.now();
      await _upsertProgress(
        animeId: animeId,
        watchedEpisodes: nextEpisode,
        updatedAt: now,
      );
      await _touchLibraryEntry(animeId, now);
    });
  }

  @override
  Future<void> setEpisode(String animeId, int episode, {int? episodesTotal}) {
    _validateEpisodesTotal(episodesTotal);

    return _database.transaction(() async {
      final libraryEntry = await _requireLibraryEntry(animeId);
      final status = LibraryStatus.values.byName(libraryEntry.status);

      _validateEpisode(
        episode,
        episodesTotal: episodesTotal,
        libraryStatus: status,
      );

      final now = DateTime.now();
      await _upsertProgress(
        animeId: animeId,
        watchedEpisodes: episode,
        updatedAt: now,
      );
      await _touchLibraryEntry(animeId, now);
    });
  }

  @override
  Future<void> clearProgress(String animeId) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.watchProgressEntries,
      )..where((table) => table.animeId.equals(animeId))).go();

      final libraryEntry = await _findLibraryEntry(animeId);
      if (libraryEntry != null) {
        await _touchLibraryEntry(animeId, DateTime.now());
      }
    });
  }

  Future<db.WatchProgressEntry?> _findProgress(String animeId) {
    return (_database.select(
      _database.watchProgressEntries,
    )..where((table) => table.animeId.equals(animeId))).getSingleOrNull();
  }

  Future<db.LibraryEntry?> _findLibraryEntry(String animeId) {
    return (_database.select(
      _database.libraryEntries,
    )..where((table) => table.animeId.equals(animeId))).getSingleOrNull();
  }

  Future<db.LibraryEntry> _requireLibraryEntry(String animeId) async {
    final libraryEntry = await _findLibraryEntry(animeId);
    if (libraryEntry == null) {
      throw StateError('Progress requires an existing library entry.');
    }
    return libraryEntry;
  }

  Future<void> _upsertProgress({
    required String animeId,
    required int watchedEpisodes,
    required DateTime updatedAt,
  }) {
    return _database
        .into(_database.watchProgressEntries)
        .insertOnConflictUpdate(
          db.WatchProgressEntriesCompanion.insert(
            animeId: animeId,
            watchedEpisodes: Value(watchedEpisodes),
            lastWatchedEpisode: Value(
              watchedEpisodes == 0 ? null : watchedEpisodes,
            ),
            updatedAt: updatedAt,
          ),
        );
  }

  Future<void> _touchLibraryEntry(String animeId, DateTime now) {
    return (_database.update(_database.libraryEntries)
          ..where((table) => table.animeId.equals(animeId)))
        .write(db.LibraryEntriesCompanion(lastInteractedAt: Value(now)));
  }

  static void _validateEpisodesTotal(int? episodesTotal) {
    if (episodesTotal != null && episodesTotal < 0) {
      throw RangeError.value(episodesTotal, 'episodesTotal');
    }
  }

  static void _validateEpisode(
    int episode, {
    required int? episodesTotal,
    required LibraryStatus libraryStatus,
  }) {
    if (episode < 0) {
      throw RangeError.value(episode, 'episode');
    }

    if (episodesTotal == null) {
      return;
    }

    if (episode > episodesTotal) {
      throw StateError('watchedEpisodes cannot exceed episodesTotal.');
    }

    if (libraryStatus == LibraryStatus.completed && episode < episodesTotal) {
      throw StateError(
        'completed status cannot coexist with incomplete progress.',
      );
    }
  }

  static domain.WatchProgress _toDomain(db.WatchProgressEntry row) {
    return domain.WatchProgress(
      animeId: row.animeId,
      watchedEpisodes: row.watchedEpisodes,
      lastWatchedEpisode: row.lastWatchedEpisode,
      updatedAt: row.updatedAt,
    );
  }
}

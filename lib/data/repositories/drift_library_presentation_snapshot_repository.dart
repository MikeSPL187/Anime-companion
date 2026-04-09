import 'package:drift/drift.dart';

import '../../core/database/app_database.dart' as db;
import '../../domain/enums/enums.dart';
import '../../domain/models/library_presentation_snapshot.dart' as domain;
import '../../domain/repositories/library_presentation_snapshot_repository.dart';

class DriftLibraryPresentationSnapshotRepository
    implements LibraryPresentationSnapshotRepository {
  DriftLibraryPresentationSnapshotRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<Map<String, domain.LibraryPresentationSnapshot>> watchAll() {
    final query = _database.select(_database.libraryPresentationSnapshots);

    return query.watch().map((rows) {
      return {for (final row in rows) row.animeId: _toDomain(row)};
    });
  }

  @override
  Stream<domain.LibraryPresentationSnapshot?> watchByAnimeId(String animeId) {
    final query = _database.select(_database.libraryPresentationSnapshots)
      ..where((table) => table.animeId.equals(animeId));

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toDomain(row),
    );
  }

  @override
  Future<domain.LibraryPresentationSnapshot?> getByAnimeId(
    String animeId,
  ) async {
    final row = await _findByAnimeId(animeId);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> saveSnapshot(domain.LibraryPresentationSnapshot snapshot) {
    return _saveSnapshot(_database, snapshot);
  }

  @override
  Future<void> removeSnapshot(String animeId) {
    return (_database.delete(
      _database.libraryPresentationSnapshots,
    )..where((table) => table.animeId.equals(animeId))).go();
  }

  Future<db.LibraryPresentationSnapshot?> _findByAnimeId(String animeId) {
    return (_database.select(
      _database.libraryPresentationSnapshots,
    )..where((table) => table.animeId.equals(animeId))).getSingleOrNull();
  }

  static Future<void> saveSnapshotInDatabase(
    db.AppDatabase database,
    domain.LibraryPresentationSnapshot snapshot,
  ) {
    return _saveSnapshot(database, snapshot);
  }

  static Future<void> _saveSnapshot(
    db.AppDatabase database,
    domain.LibraryPresentationSnapshot snapshot,
  ) {
    return database
        .into(database.libraryPresentationSnapshots)
        .insertOnConflictUpdate(
          db.LibraryPresentationSnapshotsCompanion.insert(
            animeId: snapshot.animeId,
            title: snapshot.title,
            altTitle: Value(snapshot.altTitle),
            posterUrl: Value(snapshot.posterUrl),
            animeType: Value(snapshot.type?.name),
            year: Value(snapshot.year),
            episodesTotal: Value(snapshot.episodesTotal),
            favoritesCount: Value(snapshot.favoritesCount),
            snapshotSavedAt: snapshot.snapshotSavedAt,
          ),
        );
  }

  static domain.LibraryPresentationSnapshot _toDomain(
    db.LibraryPresentationSnapshot row,
  ) {
    return domain.LibraryPresentationSnapshot(
      animeId: row.animeId,
      title: row.title,
      altTitle: row.altTitle,
      posterUrl: row.posterUrl,
      type: _readAnimeType(row.animeType),
      year: row.year,
      episodesTotal: row.episodesTotal,
      favoritesCount: row.favoritesCount,
      snapshotSavedAt: row.snapshotSavedAt,
    );
  }

  static AnimeType? _readAnimeType(String? value) {
    if (value == null) {
      return null;
    }

    for (final type in AnimeType.values) {
      if (type.name == value) {
        return type;
      }
    }

    return AnimeType.unknown;
  }
}

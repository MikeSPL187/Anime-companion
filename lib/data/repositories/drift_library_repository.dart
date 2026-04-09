import 'package:drift/drift.dart';

import '../../core/database/app_database.dart' as db;
import '../../domain/enums/enums.dart';
import '../../domain/models/library_entry.dart' as domain;
import '../../domain/models/library_presentation_snapshot.dart';
import '../../domain/repositories/library_repository.dart';
import 'drift_library_presentation_snapshot_repository.dart';

class DriftLibraryRepository implements LibraryRepository {
  DriftLibraryRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<domain.LibraryEntry>> watchAll() {
    final query = _database.select(_database.libraryEntries)
      ..orderBy([
        (table) => OrderingTerm.desc(table.lastInteractedAt),
        (table) => OrderingTerm.asc(table.animeId),
      ]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<domain.LibraryEntry>> watchByStatus(LibraryStatus status) {
    final query = _database.select(_database.libraryEntries)
      ..where((table) => table.status.equals(status.name))
      ..orderBy([
        (table) => OrderingTerm.desc(table.lastInteractedAt),
        (table) => OrderingTerm.asc(table.animeId),
      ]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<domain.LibraryEntry?> getByAnimeId(String animeId) async {
    final row = await _findByAnimeId(animeId);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> setStatus(
    String animeId,
    LibraryStatus status, {
    LibraryPresentationSnapshot? snapshot,
  }) async {
    _validateSnapshotAnimeId(animeId, snapshot);

    if (snapshot != null) {
      return _database.transaction(() async {
        await _saveSnapshot(snapshot);
        await _setStatusOnly(animeId, status);
      });
    }

    await _setStatusOnly(animeId, status);
  }

  Future<void> _setStatusOnly(String animeId, LibraryStatus status) async {
    final now = DateTime.now();
    final existing = await _findByAnimeId(animeId);

    if (existing == null) {
      await _database
          .into(_database.libraryEntries)
          .insert(
            db.LibraryEntriesCompanion.insert(
              animeId: animeId,
              status: status.name,
              isFavorite: false,
              createdAt: now,
              updatedAt: now,
              lastInteractedAt: now,
            ),
          );
      return;
    }

    if (existing.status == status.name) {
      return;
    }

    await (_database.update(
      _database.libraryEntries,
    )..where((table) => table.animeId.equals(animeId))).write(
      db.LibraryEntriesCompanion(
        status: Value(status.name),
        updatedAt: Value(now),
        lastInteractedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> toggleFavorite(
    String animeId, {
    LibraryPresentationSnapshot? snapshot,
  }) async {
    _validateSnapshotAnimeId(animeId, snapshot);

    if (snapshot != null) {
      return _database.transaction(() async {
        final existing = await _findByAnimeId(animeId);
        if (existing == null) {
          return;
        }

        await _saveSnapshot(snapshot);
        await _toggleFavoriteOnly(animeId, existing);
      });
    }

    final now = DateTime.now();
    final existing = await _findByAnimeId(animeId);

    if (existing == null) {
      return;
    }

    await _toggleFavoriteOnly(animeId, existing, now: now);
  }

  Future<void> _toggleFavoriteOnly(
    String animeId,
    db.LibraryEntry existing, {
    DateTime? now,
  }) async {
    await (_database.update(
      _database.libraryEntries,
    )..where((table) => table.animeId.equals(animeId))).write(
      db.LibraryEntriesCompanion(
        isFavorite: Value(!existing.isFavorite),
        lastInteractedAt: Value(now ?? DateTime.now()),
      ),
    );
  }

  @override
  Future<void> removeFromLibrary(String animeId) {
    return (_database.delete(
      _database.libraryEntries,
    )..where((table) => table.animeId.equals(animeId))).go();
  }

  @override
  Future<void> updateNote(String animeId, String? note) async {
    final existing = await _findByAnimeId(animeId);
    if (existing == null) {
      return;
    }

    final normalizedNote = _normalizeNote(note);
    if (existing.note == normalizedNote) {
      return;
    }

    await (_database.update(
      _database.libraryEntries,
    )..where((table) => table.animeId.equals(animeId))).write(
      db.LibraryEntriesCompanion(
        note: Value(normalizedNote),
        lastInteractedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<db.LibraryEntry?> _findByAnimeId(String animeId) {
    return (_database.select(
      _database.libraryEntries,
    )..where((table) => table.animeId.equals(animeId))).getSingleOrNull();
  }

  Future<void> _saveSnapshot(LibraryPresentationSnapshot snapshot) {
    return DriftLibraryPresentationSnapshotRepository.saveSnapshotInDatabase(
      _database,
      snapshot,
    );
  }

  static void _validateSnapshotAnimeId(
    String animeId,
    LibraryPresentationSnapshot? snapshot,
  ) {
    if (snapshot != null && snapshot.animeId != animeId) {
      throw ArgumentError.value(
        snapshot.animeId,
        'snapshot.animeId',
        'Snapshot animeId must match the library entry animeId.',
      );
    }
  }

  static String? _normalizeNote(String? note) {
    final trimmed = note?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static domain.LibraryEntry _toDomain(db.LibraryEntry row) {
    return domain.LibraryEntry(
      animeId: row.animeId,
      status: LibraryStatus.values.byName(row.status),
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastInteractedAt: row.lastInteractedAt,
      note: row.note,
    );
  }
}

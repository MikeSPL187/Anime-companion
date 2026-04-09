import 'package:drift/drift.dart';

import '../../core/database/app_database.dart' as db;
import '../../domain/models/search_history_entry.dart' as domain;
import '../../domain/repositories/search_history_repository.dart';

class DriftSearchHistoryRepository implements SearchHistoryRepository {
  DriftSearchHistoryRepository(this._database);

  static const int maxEntries = 20;

  final db.AppDatabase _database;

  @override
  Future<List<domain.SearchHistoryEntry>> getRecent({int limit = 10}) async {
    if (limit <= 0) {
      return const [];
    }

    final query = _database.select(_database.searchHistoryEntries)
      ..orderBy([
        (table) => OrderingTerm.desc(table.usedAt),
        (table) => OrderingTerm.asc(table.query),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> saveQuery(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return Future<void>.value();
    }

    return _database.transaction(() async {
      await _database
          .into(_database.searchHistoryEntries)
          .insertOnConflictUpdate(
            db.SearchHistoryEntriesCompanion.insert(
              query: normalizedQuery,
              usedAt: DateTime.now(),
            ),
          );
      await _pruneOldestEntries();
    });
  }

  @override
  Future<void> removeQuery(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return Future<void>.value();
    }

    return (_database.delete(
      _database.searchHistoryEntries,
    )..where((table) => table.query.equals(normalizedQuery))).go();
  }

  @override
  Future<void> clearAll() {
    return _database.delete(_database.searchHistoryEntries).go();
  }

  Future<void> _pruneOldestEntries() async {
    final rows =
        await (_database.select(_database.searchHistoryEntries)..orderBy([
              (table) => OrderingTerm.asc(table.usedAt),
              (table) => OrderingTerm.asc(table.query),
            ]))
            .get();

    final overflowCount = rows.length - maxEntries;
    if (overflowCount <= 0) {
      return;
    }

    final oldestQueries = rows.take(overflowCount).map((row) => row.query);
    for (final query in oldestQueries) {
      await (_database.delete(
        _database.searchHistoryEntries,
      )..where((table) => table.query.equals(query))).go();
    }
  }

  static domain.SearchHistoryEntry _toDomain(db.SearchHistoryEntry row) {
    return domain.SearchHistoryEntry(query: row.query, usedAt: row.usedAt);
  }
}

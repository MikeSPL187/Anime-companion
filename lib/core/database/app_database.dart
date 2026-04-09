import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LibraryEntries extends Table {
  @override
  String get tableName => 'library_entries';

  TextColumn get animeId => text().named('anime_id')();
  TextColumn get status => text()();
  BoolColumn get isFavorite => boolean().named('is_favorite')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get lastInteractedAt =>
      dateTime().named('last_interacted_at')();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {animeId};
}

class WatchProgressEntries extends Table {
  @override
  String get tableName => 'watch_progress_entries';

  TextColumn get animeId => text().named('anime_id')();
  IntColumn get watchedEpisodes =>
      integer().named('watched_episodes').withDefault(const Constant(0))();
  IntColumn get lastWatchedEpisode =>
      integer().named('last_watched_episode').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {animeId};
}

class SearchHistoryEntries extends Table {
  @override
  String get tableName => 'search_history_entries';

  TextColumn get query => text()();
  DateTimeColumn get usedAt => dateTime().named('used_at')();

  @override
  Set<Column<Object>> get primaryKey => {query};
}

class LibraryPresentationSnapshots extends Table {
  @override
  String get tableName => 'library_presentation_snapshots';

  TextColumn get animeId => text().named('anime_id')();
  TextColumn get title => text()();
  TextColumn get altTitle => text().named('alt_title').nullable()();
  TextColumn get posterUrl => text().named('poster_url').nullable()();
  TextColumn get animeType => text().named('type').nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get episodesTotal => integer().named('episodes_total').nullable()();
  IntColumn get favoritesCount =>
      integer().named('favorites_count').nullable()();
  DateTimeColumn get snapshotSavedAt => dateTime().named('snapshot_saved_at')();

  @override
  Set<Column<Object>> get primaryKey => {animeId};
}

class CachedSummaryLists extends Table {
  @override
  String get tableName => 'cached_summary_lists';

  TextColumn get cacheKey => text().named('cache_key')();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

class CachedReleaseDetails extends Table {
  @override
  String get tableName => 'cached_release_details';

  TextColumn get animeId => text().named('anime_id')();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  Set<Column<Object>> get primaryKey => {animeId};
}

class CachedFranchiseData extends Table {
  @override
  String get tableName => 'cached_franchise_data';

  TextColumn get releaseId => text().named('release_id')();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  Set<Column<Object>> get primaryKey => {releaseId};
}

class CachedScheduleData extends Table {
  @override
  String get tableName => 'cached_schedule_data';

  TextColumn get scope => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  Set<Column<Object>> get primaryKey => {scope};
}

@DriftDatabase(
  tables: [
    LibraryEntries,
    WatchProgressEntries,
    SearchHistoryEntries,
    LibraryPresentationSnapshots,
    CachedSummaryLists,
    CachedReleaseDetails,
    CachedFranchiseData,
    CachedScheduleData,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(libraryPresentationSnapshots);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ani_app.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

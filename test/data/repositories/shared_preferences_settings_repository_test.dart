import 'package:ani_app/core/cache/cache_keys.dart';
import 'package:ani_app/core/database/app_database.dart' as db;
import 'package:ani_app/data/repositories/shared_preferences_settings_repository.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late db.AppDatabase database;
  late SharedPreferences preferences;
  late SharedPreferencesSettingsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    database = db.AppDatabase(NativeDatabase.memory());
    repository = SharedPreferencesSettingsRepository(
      preferences: preferences,
      database: database,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('stores theme and refresh behavior preferences locally', () async {
    expect(await repository.getThemeMode(), AppThemeMode.system);
    expect(
      await repository.getRefreshBehavior(),
      RefreshBehavior.staleWhileRevalidate,
    );

    await repository.setThemeMode(AppThemeMode.dark);
    await repository.setRefreshBehavior(RefreshBehavior.manual);

    expect(await repository.getThemeMode(), AppThemeMode.dark);
    expect(await repository.getRefreshBehavior(), RefreshBehavior.manual);
  });

  test('clearCache removes only remote cache tables', () async {
    final fetchedAt = DateTime(2026, 4, 9);
    await database
        .into(database.cachedSummaryLists)
        .insert(
          db.CachedSummaryListsCompanion.insert(
            cacheKey: CacheKeys.summaryList(scope: 'latest', page: 1),
            payload: '{}',
            fetchedAt: fetchedAt,
          ),
        );
    await database
        .into(database.cachedReleaseDetails)
        .insert(
          db.CachedReleaseDetailsCompanion.insert(
            animeId: '413',
            payload: '{}',
            fetchedAt: fetchedAt,
          ),
        );
    await database
        .into(database.cachedFranchiseData)
        .insert(
          db.CachedFranchiseDataCompanion.insert(
            releaseId: '413',
            payload: '{}',
            fetchedAt: fetchedAt,
          ),
        );
    await database
        .into(database.cachedScheduleData)
        .insert(
          db.CachedScheduleDataCompanion.insert(
            scope: CacheScopes.scheduleWeek,
            payload: '[]',
            fetchedAt: fetchedAt,
          ),
        );
    await database
        .into(database.searchHistoryEntries)
        .insert(
          db.SearchHistoryEntriesCompanion.insert(
            query: 'наруто',
            usedAt: fetchedAt,
          ),
        );

    await repository.clearCache();

    expect(await database.select(database.cachedSummaryLists).get(), isEmpty);
    expect(await database.select(database.cachedReleaseDetails).get(), isEmpty);
    expect(await database.select(database.cachedFranchiseData).get(), isEmpty);
    expect(await database.select(database.cachedScheduleData).get(), isEmpty);
    expect(
      await database.select(database.searchHistoryEntries).get(),
      hasLength(1),
    );
  });
}

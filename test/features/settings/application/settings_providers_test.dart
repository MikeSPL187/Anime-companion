import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/data/providers/settings_repository_provider.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/search_history_entry.dart';
import 'package:ani_app/domain/repositories/search_history_repository.dart';
import 'package:ani_app/domain/repositories/settings_repository.dart';
import 'package:ani_app/features/settings/application/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings actions persist theme and clear search history', () async {
    final settingsRepository = FakeSettingsRepository();
    final searchHistoryRepository = FakeSearchHistoryRepository([
      SearchHistoryEntry(query: 'наруто', usedAt: DateTime(2026, 4, 9)),
    ]);
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWith(
          (ref) async => settingsRepository,
        ),
        searchHistoryRepositoryProvider.overrideWithValue(
          searchHistoryRepository,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(settingsThemeModeProvider.future),
      AppThemeMode.system,
    );
    expect(await container.read(settingsSearchHistoryCountProvider.future), 1);

    await container
        .read(settingsActionsProvider)
        .setThemeMode(AppThemeMode.dark);
    expect(
      await container.read(settingsThemeModeProvider.future),
      AppThemeMode.dark,
    );

    await container.read(settingsActionsProvider).clearSearchHistory();
    expect(searchHistoryRepository.entries, isEmpty);
    expect(await container.read(settingsSearchHistoryCountProvider.future), 0);
  });
}

class FakeSettingsRepository implements SettingsRepository {
  AppThemeMode themeMode = AppThemeMode.system;
  RefreshBehavior refreshBehavior = RefreshBehavior.staleWhileRevalidate;
  bool cacheCleared = false;

  @override
  Future<AppThemeMode> getThemeMode() async {
    return themeMode;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    themeMode = mode;
  }

  @override
  Future<RefreshBehavior> getRefreshBehavior() async {
    return refreshBehavior;
  }

  @override
  Future<void> setRefreshBehavior(RefreshBehavior behavior) async {
    refreshBehavior = behavior;
  }

  @override
  Future<void> clearCache() async {
    cacheCleared = true;
  }
}

class FakeSearchHistoryRepository implements SearchHistoryRepository {
  FakeSearchHistoryRepository(this.entries);

  final List<SearchHistoryEntry> entries;

  @override
  Future<List<SearchHistoryEntry>> getRecent({int limit = 10}) async {
    return entries.take(limit).toList();
  }

  @override
  Future<void> saveQuery(String query) async {
    entries.add(SearchHistoryEntry(query: query, usedAt: DateTime.now()));
  }

  @override
  Future<void> removeQuery(String query) async {
    entries.removeWhere((entry) => entry.query == query);
  }

  @override
  Future<void> clearAll() async {
    entries.clear();
  }
}

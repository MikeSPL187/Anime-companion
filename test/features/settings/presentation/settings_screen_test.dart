import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/data/providers/settings_repository_provider.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/search_history_entry.dart';
import 'package:ani_app/domain/repositories/search_history_repository.dart';
import 'package:ani_app/domain/repositories/settings_repository.dart';
import 'package:ani_app/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders trust settings and persists theme selection', (
    tester,
  ) async {
    final settingsRepository = FakeSettingsRepository();

    await tester.pumpWidget(
      _testApp(
        settingsRepository: settingsRepository,
        searchHistoryRepository: FakeSearchHistoryRepository(const []),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Внешний вид'), findsOneWidget);
    expect(find.text('Источник данных и доверие'), findsOneWidget);
    expect(find.text('AniLibria project / AniLiberty API v1'), findsOneWidget);
    expect(find.text('Local-first companion'), findsOneWidget);

    await tester.tap(find.text('Тёмная'));
    await tester.pump();

    expect(settingsRepository.themeMode, AppThemeMode.dark);
  });

  testWidgets('clears cache and search history after confirmation', (
    tester,
  ) async {
    final settingsRepository = FakeSettingsRepository();
    final searchHistoryRepository = FakeSearchHistoryRepository([
      SearchHistoryEntry(query: 'наруто', usedAt: DateTime(2026, 4, 9)),
    ]);

    await tester.pumpWidget(
      _testApp(
        settingsRepository: settingsRepository,
        searchHistoryRepository: searchHistoryRepository,
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Очистить сетевой кеш'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Очистить'));
    await tester.pumpAndSettle();

    expect(settingsRepository.cacheCleared, isTrue);
    expect(find.text('Кеш очищен'), findsOneWidget);

    await tester.tap(find.text('Очистить историю поиска'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Очистить'));
    await tester.pumpAndSettle();

    expect(searchHistoryRepository.entries, isEmpty);
    expect(find.text('История поиска очищена'), findsOneWidget);
  });
}

Widget _testApp({
  required SettingsRepository settingsRepository,
  required SearchHistoryRepository searchHistoryRepository,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWith(
        (ref) async => settingsRepository,
      ),
      searchHistoryRepositoryProvider.overrideWithValue(
        searchHistoryRepository,
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
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
  FakeSearchHistoryRepository(List<SearchHistoryEntry> entries)
    : entries = [...entries];

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

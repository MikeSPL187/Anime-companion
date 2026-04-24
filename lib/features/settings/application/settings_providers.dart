import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_provider.dart';
import '../../../data/providers/local_repository_providers.dart';
import '../../../data/providers/settings_repository_provider.dart';
import '../../../domain/enums/enums.dart';

final settingsThemeModeProvider = appThemeModeProvider;

final settingsSearchHistoryCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final entries = await ref
      .watch(searchHistoryRepositoryProvider)
      .getRecent(limit: 20);
  return entries.length;
});

final settingsActionsProvider = Provider.autoDispose<SettingsActions>((ref) {
  return SettingsActions(ref);
});

class SettingsActions {
  const SettingsActions(this._ref);

  final Ref _ref;

  Future<void> setThemeMode(AppThemeMode mode) async {
    final repository = await _ref.read(settingsRepositoryProvider.future);
    await repository.setThemeMode(mode);
    _ref.invalidate(appThemeModeProvider);
  }

  Future<void> clearCache() async {
    final repository = await _ref.read(settingsRepositoryProvider.future);
    await repository.clearCache();
  }

  Future<void> clearSearchHistory() async {
    await _ref.read(searchHistoryRepositoryProvider).clearAll();
    _ref.invalidate(settingsSearchHistoryCountProvider);
  }
}

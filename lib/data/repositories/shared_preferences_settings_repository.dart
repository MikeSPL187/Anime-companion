import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart' as db;
import '../../domain/enums/enums.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository({
    required SharedPreferences preferences,
    required db.AppDatabase database,
  }) : _preferences = preferences,
       _database = database;

  static const _themeModeKey = 'settings.theme_mode';
  static const _refreshBehaviorKey = 'settings.refresh_behavior';

  final SharedPreferences _preferences;
  final db.AppDatabase _database;

  @override
  Future<AppThemeMode> getThemeMode() async {
    return _readEnum(
      key: _themeModeKey,
      values: AppThemeMode.values,
      fallback: AppThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) {
    return _preferences.setString(_themeModeKey, mode.name);
  }

  @override
  Future<RefreshBehavior> getRefreshBehavior() async {
    return _readEnum(
      key: _refreshBehaviorKey,
      values: RefreshBehavior.values,
      fallback: RefreshBehavior.staleWhileRevalidate,
    );
  }

  @override
  Future<void> setRefreshBehavior(RefreshBehavior behavior) {
    return _preferences.setString(_refreshBehaviorKey, behavior.name);
  }

  @override
  Future<void> clearCache() {
    return _database.transaction(() async {
      await _database.delete(_database.cachedSummaryLists).go();
      await _database.delete(_database.cachedReleaseDetails).go();
      await _database.delete(_database.cachedFranchiseData).go();
      await _database.delete(_database.cachedScheduleData).go();
    });
  }

  T _readEnum<T extends Enum>({
    required String key,
    required List<T> values,
    required T fallback,
  }) {
    final value = _preferences.getString(key);
    if (value == null) {
      return fallback;
    }

    for (final enumValue in values) {
      if (enumValue.name == value) {
        return enumValue;
      }
    }

    return fallback;
  }
}

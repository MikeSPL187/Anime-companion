import '../enums/enums.dart';

abstract interface class SettingsRepository {
  Future<AppThemeMode> getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode);

  Future<RefreshBehavior> getRefreshBehavior();

  Future<void> setRefreshBehavior(RefreshBehavior behavior);

  Future<void> clearCache();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database_provider.dart';
import '../../core/preferences/shared_preferences_provider.dart';
import '../../domain/repositories/settings_repository.dart';
import '../repositories/shared_preferences_settings_repository.dart';

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);

  return SharedPreferencesSettingsRepository(
    preferences: preferences,
    database: ref.watch(appDatabaseProvider),
  );
});

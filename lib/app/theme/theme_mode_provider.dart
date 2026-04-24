import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/settings_repository_provider.dart';
import '../../domain/enums/enums.dart';

final appThemeModeProvider = FutureProvider<AppThemeMode>((ref) async {
  final repository = await ref.watch(settingsRepositoryProvider.future);
  return repository.getThemeMode();
});

ThemeMode toFlutterThemeMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

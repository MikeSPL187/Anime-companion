import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_provider.dart';

class AniApp extends ConsumerWidget {
  const AniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider).value;

    return MaterialApp.router(
      title: 'Аниме-компаньон',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode == null
          ? ThemeMode.system
          : toFlutterThemeMode(themeMode),
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

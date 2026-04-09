import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/enums.dart';
import '../../../shared/widgets/action_feedback.dart';
import '../application/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsThemeModeProvider);
    final searchHistoryCount = ref.watch(settingsSearchHistoryCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsSection(
              title: 'Внешний вид',
              children: [
                RadioGroup<AppThemeMode>(
                  groupValue: themeMode.value ?? AppThemeMode.system,
                  onChanged: themeMode.isLoading
                      ? (_) {}
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          _setThemeMode(context, ref, value);
                        },
                  child: Column(
                    children: [
                      for (final mode in AppThemeMode.values)
                        RadioListTile<AppThemeMode>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_themeModeLabel(mode)),
                          subtitle: Text(_themeModeDescription(mode)),
                          value: mode,
                          enabled: !themeMode.isLoading,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Данные и кеш',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Очистить сетевой кеш'),
                  subtitle: const Text(
                    'Удалит кеш каталога, деталей, франшиз и расписания. Библиотека и прогресс останутся.',
                  ),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () => _clearCache(context, ref),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Очистить историю поиска'),
                  subtitle: Text(
                    searchHistoryCount.when(
                      data: (count) => count == 0
                          ? 'Недавних запросов нет'
                          : 'Сейчас сохранено: $count',
                      error: (error, stackTrace) =>
                          'Не удалось прочитать историю поиска',
                      loading: () => 'Проверяем историю поиска',
                    ),
                  ),
                  trailing: const Icon(Icons.history_toggle_off),
                  enabled: (searchHistoryCount.value ?? 0) > 0,
                  onTap: (searchHistoryCount.value ?? 0) == 0
                      ? null
                      : () => _clearSearchHistory(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SettingsSection(
              title: 'Источник данных и доверие',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('AniLibria project / AniLiberty API v1'),
                  subtitle: Text(
                    'Каталог, детали, франшизы и расписание загружаются из AniLiberty API v1. Свежесть зависит от провайдера и локального кеша.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Local-first companion'),
                  subtitle: Text(
                    'Библиотека, избранное, прогресс, заметки и история поиска хранятся локально на устройстве. Это не стриминговое приложение.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SettingsSection(
              title: 'О приложении',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Аниме-компаньон'),
                  subtitle: Text(
                    'Личный трекер аниме для поиска, библиотеки, прогресса и расписания.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Column(
          children: [
            for (var index = 0; index < children.length; index += 1) ...[
              children[index],
              if (index < children.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ],
    );
  }
}

Future<void> _setThemeMode(
  BuildContext context,
  WidgetRef ref,
  AppThemeMode mode,
) async {
  try {
    await ref.read(settingsActionsProvider).setThemeMode(mode);
  } catch (error) {
    if (context.mounted) {
      showActionErrorSnackBar(context, 'Не удалось сохранить тему');
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  showActionSnackBar(context, 'Тема: ${_themeModeLabel(mode)}');
}

Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
  final confirmed = await _confirmAction(
    context,
    title: 'Очистить сетевой кеш?',
    message:
        'Личные данные останутся на устройстве. Каталог, детали, франшизы и расписание будут загружены заново при следующем открытии.',
  );
  if (!confirmed) {
    return;
  }

  try {
    await ref.read(settingsActionsProvider).clearCache();
  } catch (error) {
    if (context.mounted) {
      showActionErrorSnackBar(context, 'Не удалось очистить кеш');
    }
    return;
  }

  if (context.mounted) {
    showActionSnackBar(context, 'Кеш очищен');
  }
}

Future<void> _clearSearchHistory(BuildContext context, WidgetRef ref) async {
  final confirmed = await _confirmAction(
    context,
    title: 'Очистить историю поиска?',
    message:
        'Недавние запросы будут удалены. Библиотека и прогресс не изменятся.',
  );
  if (!confirmed) {
    return;
  }

  try {
    await ref.read(settingsActionsProvider).clearSearchHistory();
  } catch (error) {
    if (context.mounted) {
      showActionErrorSnackBar(context, 'Не удалось очистить историю поиска');
    }
    return;
  }

  if (context.mounted) {
    showActionSnackBar(context, 'История поиска очищена');
  }
}

Future<bool> _confirmAction(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

String _themeModeLabel(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => 'Как в системе',
    AppThemeMode.light => 'Светлая',
    AppThemeMode.dark => 'Тёмная',
  };
}

String _themeModeDescription(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => 'Использовать настройку Android',
    AppThemeMode.light => 'Всегда светлая тема',
    AppThemeMode.dark => 'Всегда тёмная тема',
  };
}

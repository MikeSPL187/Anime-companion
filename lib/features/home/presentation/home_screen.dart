import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/error/app_error.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../shared/utils/anime_labels.dart';
import '../../../shared/widgets/action_feedback.dart';
import '../../../shared/widgets/anime_poster_image.dart';
import '../../../shared/widgets/presentation_chips.dart';
import '../application/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryEntries = ref.watch(homeLibraryEntriesProvider);
    final continueItems = ref.watch(homeContinueItemsProvider);
    final schedulePreview = ref.watch(homeSchedulePreviewProvider);
    final whatNextItems = ref.watch(homeWhatNextItemsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HomeHeader(entries: libraryEntries.value ?? const []),
            const SizedBox(height: 20),
            continueItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _ContinueSection(items: items);
              },
              error: (error, stackTrace) => const _SectionError(
                title: 'Продолжить',
                message: 'Не удалось прочитать активные тайтлы',
              ),
              loading: () => const _HomeSectionSkeleton(title: 'Продолжить'),
            ),
            const SizedBox(height: 20),
            schedulePreview.when(
              data: (preview) => _ScheduleSection(preview: preview),
              error: (error, stackTrace) => _SectionError(
                title: 'Моё расписание',
                message: _errorMessage(error),
              ),
              loading: () =>
                  const _HomeSectionSkeleton(title: 'Моё расписание'),
            ),
            const SizedBox(height: 20),
            whatNextItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _WhatNextSection(items: items);
              },
              error: (error, stackTrace) => const _SectionError(
                title: 'Что дальше',
                message: 'Не удалось прочитать список',
              ),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.entries});

  final List<LibraryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final watchingCount = entries
        .where((entry) => entry.status == LibraryStatus.watching)
        .length;
    final plannedCount = entries
        .where((entry) => entry.status == LibraryStatus.planned)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Сегодня', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          entries.isEmpty
              ? 'Добавь тайтлы в библиотеку, чтобы собрать свой рабочий стол.'
              : 'В работе: $watchingCount · в планах: $plannedCount',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.library),
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Библиотека'),
            ),
            if (entries.isEmpty)
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.search),
                icon: const Icon(Icons.search),
                label: const Text('Найти аниме'),
              ),
          ],
        ),
      ],
    );
  }
}

class _ContinueSection extends StatelessWidget {
  const _ContinueSection({required this.items});

  final List<HomeLibraryItem> items;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      title: 'Продолжить',
      trailing: TextButton(
        onPressed: () => context.go(AppRoutes.library),
        child: const Text('Все'),
      ),
      child: Column(
        children: [
          for (final item in items) ...[
            _HomeLibraryCard(item: item, showIncrementAction: true),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.preview});

  final HomeSchedulePreview preview;

  @override
  Widget build(BuildContext context) {
    final items = preview.items;

    return _HomeSection(
      title: 'Моё расписание',
      subtitle: freshnessLabel(preview.fetchedAt),
      child: items.isEmpty
          ? const _EmptyText(
              text:
                  'Добавь онгоинги в «Смотрю» или избранное, чтобы видеть их здесь.',
            )
          : Column(
              children: [
                for (final item in items) ...[
                  _SchedulePreviewTile(item: item),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _WhatNextSection extends StatelessWidget {
  const _WhatNextSection({required this.items});

  final List<HomeLibraryItem> items;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      title: 'Что дальше',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Тайтлы из планов, к которым давно не возвращались.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            _HomeLibraryCard(item: item, showIncrementAction: false),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final subtitleValue = subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitleValue != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleValue,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _HomeLibraryCard extends ConsumerWidget {
  const _HomeLibraryCard({
    required this.item,
    required this.showIncrementAction,
  });

  final HomeLibraryItem item;
  final bool showIncrementAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = item.entry;
    final snapshot = item.snapshot;
    final progress = ref.watch(
      homeProgressProvider(entry.animeId).select((value) {
        final progress = value.value;
        return (
          existedBefore: progress != null,
          watchedEpisodes: progress?.watchedEpisodes ?? 0,
        );
      }),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => context.push(AppRoutes.animeDetails(entry.animeId)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: AnimePosterImage(
                  imageUrl: snapshot?.posterUrl,
                  semanticLabel: snapshot?.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HomeLibraryInfo(
                  entry: entry,
                  snapshot: snapshot,
                  watchedEpisodes: progress.watchedEpisodes,
                ),
              ),
              if (showIncrementAction) ...[
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    _incrementWithUndo(
                      context: context,
                      ref: ref,
                      animeId: entry.animeId,
                      episodesTotal: snapshot?.episodesTotal,
                      progressExistedBefore: progress.existedBefore,
                      watchedEpisodes: progress.watchedEpisodes,
                    );
                  },
                  child: const Text('+1'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLibraryInfo extends StatelessWidget {
  const _HomeLibraryInfo({
    required this.entry,
    required this.snapshot,
    required this.watchedEpisodes,
  });

  final LibraryEntry entry;
  final LibraryPresentationSnapshot? snapshot;
  final int watchedEpisodes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          libraryEntryTitle(entry.animeId, snapshot),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppInfoChip(label: libraryStatusLabel(entry.status)),
            AppInfoChip(
              label: progressLabel(watchedEpisodes, snapshot?.episodesTotal),
            ),
            if (entry.isFavorite) const FavoriteInfoChip(),
          ],
        ),
      ],
    );
  }
}

class _SchedulePreviewTile extends StatelessWidget {
  const _SchedulePreviewTile({required this.item});

  final HomeSchedulePreviewItem item;

  @override
  Widget build(BuildContext context) {
    final schedule = item.scheduleItem;
    final snapshot = item.snapshot;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 44,
        child: AnimePosterImage(
          imageUrl: snapshotPosterOr(schedule.posterUrl, snapshot),
          semanticLabel: snapshotTitleOr(schedule.title, snapshot),
        ),
      ),
      title: Text(
        snapshotTitleOr(schedule.title, snapshot),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${publishDayLabel(schedule.publishDay)} · ${_schedulePriorityLabel(item.priority)}',
      ),
      onTap: () => context.push(AppRoutes.animeDetails(schedule.releaseId)),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      title: title,
      child: _EmptyText(text: message),
    );
  }
}

class _HomeSectionSkeleton extends StatelessWidget {
  const _HomeSectionSkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return _HomeSection(
      title: title,
      child: Column(
        children: [
          for (var index = 0; index < 2; index += 1) ...[
            Row(
              children: [
                const SizedBox(width: 64, child: AnimePosterImage()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBlock(width: double.infinity, color: color),
                      const SizedBox(height: 8),
                      _SkeletonBlock(width: 180, color: color),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

Future<void> _incrementWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required String animeId,
  required int? episodesTotal,
  required bool progressExistedBefore,
  required int watchedEpisodes,
}) async {
  final actions = ref.read(homeActionsProvider);

  try {
    await actions.incrementEpisode(animeId, episodesTotal: episodesTotal);
  } catch (error) {
    if (context.mounted) {
      showActionErrorSnackBar(context, 'Не удалось обновить прогресс');
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  showUndoSnackBar(
    context,
    message: 'Прогресс обновлён',
    onUndo: () {
      unawaited(
        actions.restoreProgress(
          animeId: animeId,
          existedBefore: progressExistedBefore,
          watchedEpisodes: watchedEpisodes,
        ),
      );
    },
  );
}

String _schedulePriorityLabel(HomeSchedulePriority priority) {
  return switch (priority) {
    HomeSchedulePriority.watching => 'из «Смотрю»',
    HomeSchedulePriority.favorite => 'из избранного',
  };
}

String _errorMessage(Object error) {
  return switch (error) {
    NetworkError() => 'Не удалось загрузить расписание',
    NotFoundError() => 'Расписание не найдено',
    ParseError() => 'Не удалось прочитать расписание',
    CacheError() => 'Не удалось прочитать локальные данные',
    UnknownError() => 'Что-то пошло не так',
    _ => 'Что-то пошло не так',
  };
}

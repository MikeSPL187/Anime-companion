import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/error/app_error.dart';
import '../../../shared/utils/anime_labels.dart';
import '../../../shared/widgets/anime_poster_image.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/presentation_chips.dart';
import '../application/schedule_providers.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(scheduleScreenStateProvider);
    final refreshState = ref.watch(scheduleRefreshControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref
                .read(scheduleRefreshControllerProvider.notifier)
                .refresh();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ScheduleHeader(
                fetchedAt: screenState.value?.fetchedAt,
                isStale: screenState.value?.isStale ?? false,
                refreshState: refreshState,
                onRefresh: () {
                  ref
                      .read(scheduleRefreshControllerProvider.notifier)
                      .refresh();
                },
              ),
              const SizedBox(height: 18),
              screenState.when(
                data: (state) => _ScheduleContent(state: state),
                error: (error, stackTrace) => _ScheduleError(
                  message: _errorMessage(error),
                  onRetry: () {
                    ref
                        .read(scheduleRefreshControllerProvider.notifier)
                        .refresh();
                  },
                ),
                loading: () => const _ScheduleSkeleton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader({
    required this.fetchedAt,
    required this.isStale,
    required this.refreshState,
    required this.onRefresh,
  });

  final DateTime? fetchedAt;
  final bool isStale;
  final ScheduleRefreshState refreshState;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Расписание', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Личные релизы на ближайшую неделю',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _freshnessLabel(
                  fetchedAt: fetchedAt,
                  isStale: isStale,
                  refreshState: refreshState,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: refreshState.failedAt == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          tooltip: 'Обновить расписание',
          onPressed: refreshState.isRefreshing ? null : onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  const _ScheduleContent({required this.state});

  final ScheduleScreenState state;

  @override
  Widget build(BuildContext context) {
    if (state.groups.isEmpty) {
      return _ScheduleEmpty(hasPersonalEntries: state.hasPersonalEntries);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in state.groups) ...[
          _ScheduleDaySection(group: group),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _ScheduleDaySection extends StatelessWidget {
  const _ScheduleDaySection({required this.group});

  final ScheduleDayGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dayGroupTitle(group),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final item in group.items) ...[
          _ScheduleRow(item: item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});

  final ScheduleRowItem item;

  @override
  Widget build(BuildContext context) {
    final scheduleItem = item.scheduleItem;
    final snapshot = item.snapshot;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.animeDetails(scheduleItem.releaseId)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: AnimePosterImage(
                  imageUrl: snapshotPosterOr(scheduleItem.posterUrl, snapshot),
                  semanticLabel: snapshotTitleOr(scheduleItem.title, snapshot),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshotTitleOr(scheduleItem.title, snapshot),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AppInfoChip(
                          label: publishDayLabel(scheduleItem.publishDay),
                        ),
                        AppInfoChip(label: _relevanceLabel(item.relevance)),
                        if (item.entry.isFavorite &&
                            item.relevance != ScheduleRelevance.favorite)
                          const FavoriteInfoChip(),
                        if (scheduleItem.isOngoing)
                          const AppInfoChip(label: 'Онгоинг'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleEmpty extends StatelessWidget {
  const _ScheduleEmpty({required this.hasPersonalEntries});

  final bool hasPersonalEntries;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      text: hasPersonalEntries
          ? 'На этой неделе нет релизов из «Смотрю» или избранного.'
          : 'Добавь аниме в «Смотрю», чтобы видеть своё расписание',
      supportingText:
          'Здесь появляются только тайтлы из вашей библиотеки, без общего каталога.',
      textAlign: TextAlign.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class _ScheduleError extends StatelessWidget {
  const _ScheduleError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      text: message,
      actionLabel: 'Повторить',
      onAction: onRetry,
      textAlign: TextAlign.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBlock(width: 120, height: 22, color: color),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index += 1) ...[
          Row(
            children: [
              const SizedBox(width: 56, child: AnimePosterImage()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBlock(
                      width: double.infinity,
                      height: 18,
                      color: color,
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBlock(width: 160, height: 18, color: color),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

String _dayGroupTitle(ScheduleDayGroup group) {
  return switch (group.daysUntil) {
    0 => 'Сегодня',
    1 => 'Завтра',
    _ => publishDayLabel(group.publishDay),
  };
}

String _relevanceLabel(ScheduleRelevance relevance) {
  return switch (relevance) {
    ScheduleRelevance.watching => 'Смотрю',
    ScheduleRelevance.favorite => 'Избранное',
  };
}

String _freshnessLabel({
  required DateTime? fetchedAt,
  required bool isStale,
  required ScheduleRefreshState refreshState,
}) {
  if (refreshState.failedAt != null) {
    return scheduleRefreshFailureLabel(refreshState.cachedDataFetchedAt);
  }

  return scheduleFreshnessLabel(fetchedAt: fetchedAt, isStale: isStale);
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../shared/utils/anime_labels.dart';
import '../../../shared/widgets/action_feedback.dart';
import '../../../shared/widgets/anime_poster_image.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/presentation_chips.dart';
import '../application/library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  late final TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = ref.watch(libraryFilteredEntriesProvider);
    final allEntries = ref.watch(libraryEntriesProvider);
    final selectedStatus = ref.watch(librarySelectedStatusProvider);
    final filter = ref.watch(libraryFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Библиотека', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _LibraryFilterField(
              controller: _filterController,
              onChanged: (value) {
                ref.read(libraryFilterProvider.notifier).setFilter(value);
              },
              onClear: () {
                _filterController.clear();
                ref.read(libraryFilterProvider.notifier).clear();
              },
            ),
            const SizedBox(height: 12),
            const _LibrarySegments(),
            const SizedBox(height: 16),
            filteredEntries.when(
              data: (entries) {
                final fullLibrary = allEntries.value ?? const [];
                if (fullLibrary.isEmpty) {
                  return const _AllLibraryEmptyState();
                }

                if (entries.isEmpty) {
                  return _SegmentEmptyState(
                    selectedStatus: selectedStatus,
                    hasPlannedEntries: fullLibrary.any(
                      (entry) => entry.status == LibraryStatus.planned,
                    ),
                    hasActiveFilter: filter.trim().isNotEmpty,
                  );
                }

                return _LibraryEntryList(entries: entries);
              },
              error: (error, stackTrace) => const _LibraryErrorState(),
              loading: () => const _LibrarySkeletonList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryFilterField extends StatelessWidget {
  const _LibraryFilterField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Фильтр по названию, ID или заметке',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          tooltip: 'Очистить',
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _LibrarySegments extends ConsumerWidget {
  const _LibrarySegments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(librarySelectedStatusProvider);
    final counts = ref.watch(librarySegmentCountsProvider).value;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final status in LibraryStatus.values) ...[
            ChoiceChip(
              label: Text(_segmentLabel(status, counts?[status])),
              selected: selectedStatus == status,
              onSelected: (_) {
                ref
                    .read(librarySelectedStatusProvider.notifier)
                    .setStatus(status);
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LibraryEntryList extends StatelessWidget {
  const _LibraryEntryList({required this.entries});

  final List<LibraryListItem> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries) ...[
          _LibraryEntryCard(item: entry),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LibraryEntryCard extends ConsumerWidget {
  const _LibraryEntryCard({required this.item});

  final LibraryListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = item.entry;
    final snapshot = item.snapshot;
    final progress = ref.watch(
      libraryProgressProvider(entry.animeId).select((value) {
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
                width: 70,
                child: AnimePosterImage(
                  imageUrl: snapshot?.posterUrl,
                  semanticLabel: snapshot?.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LibraryEntryInfo(
                  entry: entry,
                  snapshot: snapshot,
                  watchedEpisodes: progress.watchedEpisodes,
                ),
              ),
              const SizedBox(width: 8),
              _LibraryEntryActions(
                entry: entry,
                episodesTotal: snapshot?.episodesTotal,
                progressExistedBefore: progress.existedBefore,
                watchedEpisodes: progress.watchedEpisodes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryEntryInfo extends StatelessWidget {
  const _LibraryEntryInfo({
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
        if (snapshot?.altTitle != null) ...[
          const SizedBox(height: 2),
          Text(
            snapshot?.altTitle ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppInfoChip(label: libraryStatusLabel(entry.status)),
            if (entry.isFavorite) const FavoriteInfoChip(),
            if (snapshot?.type != null)
              AppInfoChip(label: animeTypeLabel(snapshot?.type)),
            if (snapshot?.year != null)
              AppInfoChip(label: snapshot?.year.toString() ?? ''),
            AppInfoChip(
              label: progressLabel(watchedEpisodes, snapshot?.episodesTotal),
            ),
            if (snapshot?.favoritesCount != null)
              AppInfoChip(
                label: popularityLabel(snapshot?.favoritesCount ?? 0),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Последнее действие: ${dateLabel(entry.lastInteractedAt)}',
          style: textTheme.bodySmall,
        ),
        if (entry.note != null) ...[
          const SizedBox(height: 4),
          Text(
            entry.note ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _LibraryEntryActions extends ConsumerWidget {
  const _LibraryEntryActions({
    required this.entry,
    required this.episodesTotal,
    required this.progressExistedBefore,
    required this.watchedEpisodes,
  });

  final LibraryEntry entry;
  final int? episodesTotal;
  final bool progressExistedBefore;
  final int watchedEpisodes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (entry.status == LibraryStatus.watching)
          FilledButton.tonal(
            onPressed: () {
              _incrementWithUndo(
                context: context,
                ref: ref,
                animeId: entry.animeId,
                episodesTotal: episodesTotal,
                progressExistedBefore: progressExistedBefore,
                watchedEpisodes: watchedEpisodes,
              );
            },
            child: const Text('+1'),
          ),
        PopupMenuButton<LibraryStatus>(
          tooltip: 'Изменить статус',
          onSelected: (status) {
            _setStatusWithUndo(
              context: context,
              ref: ref,
              entry: entry,
              status: status,
            );
          },
          itemBuilder: (context) => [
            for (final status in LibraryStatus.values)
              PopupMenuItem(
                value: status,
                child: Text(libraryStatusLabel(status)),
              ),
          ],
        ),
      ],
    );
  }
}

class _AllLibraryEmptyState extends StatelessWidget {
  const _AllLibraryEmptyState();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      text: 'Найди первое аниме и добавь в список',
      actionLabel: 'Перейти к поиску',
      onAction: () => context.go(AppRoutes.search),
    );
  }
}

class _SegmentEmptyState extends ConsumerWidget {
  const _SegmentEmptyState({
    required this.selectedStatus,
    required this.hasPlannedEntries,
    required this.hasActiveFilter,
  });

  final LibraryStatus selectedStatus;
  final bool hasPlannedEntries;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hasActiveFilter) {
      return const _EmptyState(text: 'Ничего не найдено в библиотеке');
    }

    if (selectedStatus == LibraryStatus.dropped) {
      return const SizedBox.shrink();
    }

    if (selectedStatus == LibraryStatus.watching && hasPlannedEntries) {
      return _EmptyState(
        text: 'Готов начать? Загляни в свой список желаний',
        actionLabel: 'Открыть список желаний',
        onAction: () {
          ref
              .read(librarySelectedStatusProvider.notifier)
              .setStatus(LibraryStatus.planned);
        },
      );
    }

    return _EmptyState(
      text: 'В разделе «${libraryStatusLabel(selectedStatus)}» пусто',
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      text: text,
      actionLabel: actionLabel,
      onAction: onAction,
      padding: const EdgeInsets.symmetric(vertical: 28),
    );
  }
}

class _LibraryErrorState extends StatelessWidget {
  const _LibraryErrorState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Text(
        'Не удалось прочитать библиотеку',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LibrarySkeletonList extends StatelessWidget {
  const _LibrarySkeletonList();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      children: [
        for (var index = 0; index < 3; index += 1) ...[
          Row(
            children: [
              const SizedBox(width: 70, child: AnimePosterImage()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBlock(width: double.infinity, color: color),
                    const SizedBox(height: 8),
                    _SkeletonBlock(width: 180, color: color),
                    const SizedBox(height: 8),
                    _SkeletonBlock(width: 220, color: color),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
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
  final actions = ref.read(libraryActionsProvider);

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

Future<void> _setStatusWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required LibraryEntry entry,
  required LibraryStatus status,
}) async {
  if (entry.status == status) {
    return;
  }

  final actions = ref.read(libraryActionsProvider);

  try {
    await actions.setStatus(entry.animeId, status);
  } catch (error) {
    if (context.mounted) {
      showActionErrorSnackBar(context, 'Не удалось изменить статус');
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  showUndoSnackBar(
    context,
    message: 'Статус: ${libraryStatusLabel(status)}',
    onUndo: () {
      unawaited(actions.setStatus(entry.animeId, entry.status));
    },
  );
}

String _segmentLabel(LibraryStatus status, int? count) {
  final label = libraryStatusLabel(status);
  return count == null ? label : '$label $count';
}

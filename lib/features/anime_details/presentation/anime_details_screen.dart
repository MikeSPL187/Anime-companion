import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/error/app_error.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/anime_details.dart';
import '../../../domain/models/anime_summary.dart';
import '../../../domain/models/franchise_entry.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/watch_progress.dart';
import '../../../shared/utils/anime_labels.dart';
import '../../../shared/widgets/action_feedback.dart';
import '../../../shared/widgets/anime_poster_image.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/presentation_chips.dart';
import '../application/anime_details_providers.dart';

class AnimeDetailsScreen extends ConsumerStatefulWidget {
  const AnimeDetailsScreen({required this.animeId, super.key});

  final String animeId;

  @override
  ConsumerState<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends ConsumerState<AnimeDetailsScreen> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(animeDetailsProvider(widget.animeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Детали аниме')),
      body: SafeArea(
        child: details.when(
          data: _buildDetails,
          error: (error, stackTrace) => _DetailsError(
            message: _errorMessage(error),
            onRetry: () {
              ref.invalidate(animeDetailsProvider(widget.animeId));
            },
          ),
          loading: () => const _DetailsSkeleton(),
        ),
      ),
    );
  }

  Widget _buildDetails(AnimeDetails details) {
    final animeId = details.summary.id;
    final libraryEntry = ref.watch(detailsLibraryEntryProvider(animeId)).value;
    final progress = ref.watch(detailsProgressProvider(animeId)).value;
    final franchise = ref.watch(animeFranchiseProvider(animeId));
    final libraryOverlay = ref.watch(detailsLibraryOverlayProvider).value ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroSection(
          details: details,
          libraryEntry: libraryEntry,
          progress: progress,
          franchiseEntries: franchise.value ?? const [],
        ),
        const SizedBox(height: 16),
        _MetadataSection(details: details, progress: progress),
        const SizedBox(height: 16),
        if (details.blockedByGeo || details.blockedByCopyright) ...[
          const _BlockedContentBanner(),
          const SizedBox(height: 16),
        ],
        _DescriptionSection(
          description: details.description,
          expanded: _descriptionExpanded,
          onToggle: () {
            setState(() {
              _descriptionExpanded = !_descriptionExpanded;
            });
          },
        ),
        const SizedBox(height: 16),
        franchise.when(
          data: (entries) => _FranchiseSection(
            currentAnimeId: animeId,
            entries: entries,
            libraryOverlay: libraryOverlay,
          ),
          error: (error, stackTrace) => const _SectionText(
            title: 'Связанное',
            text: 'Не удалось загрузить связанные тайтлы',
          ),
          loading: () => const _FranchiseSkeleton(),
        ),
        const SizedBox(height: 16),
        _AdditionalSection(details: details),
      ],
    );
  }
}

class _HeroSection extends ConsumerWidget {
  const _HeroSection({
    required this.details,
    required this.libraryEntry,
    required this.progress,
    required this.franchiseEntries,
  });

  final AnimeDetails details;
  final LibraryEntry? libraryEntry;
  final WatchProgress? progress;
  final List<FranchiseEntry> franchiseEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = details.summary;
    final progressValue = progress;
    final entry = libraryEntry;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: AnimePosterImage(
            imageUrl: summary.posterUrl,
            semanticLabel: summary.title,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (summary.altTitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  summary.altTitle ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  AppInfoChip(label: animeTypeLabel(summary.type)),
                  if (summary.year != null)
                    AppInfoChip(label: summary.year.toString()),
                  if (summary.season != null)
                    AppInfoChip(label: animeSeasonLabel(summary.season)),
                  if (summary.ageRating != null)
                    AppInfoChip(label: ageRatingLabel(summary.ageRating)),
                  if (summary.isOngoing) const AppInfoChip(label: 'Онгоинг'),
                  AppInfoChip(label: popularityLabel(summary.favoritesCount)),
                  if (entry != null)
                    LibraryStatusChip(
                      status: entry.status,
                      isFavorite: entry.isFavorite,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailsCta(
                summary: summary,
                libraryEntry: libraryEntry,
                franchiseEntries: franchiseEntries,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Избранное',
                    onPressed: libraryEntry == null
                        ? null
                        : () {
                            _toggleFavoriteWithUndo(
                              context: context,
                              ref: ref,
                              anime: summary,
                            );
                          },
                    icon: Icon(
                      libraryEntry?.isFavorite ?? false
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                  ),
                  PopupMenuButton<LibraryStatus>(
                    tooltip: 'Изменить статус',
                    onSelected: (status) {
                      _setStatusWithUndo(
                        context: context,
                        ref: ref,
                        anime: summary,
                        status: status,
                        previousEntry: libraryEntry,
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
              ),
              if (progressValue != null)
                Text(
                  watchProgressLabel(progressValue, summary.episodesTotal),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsCta extends ConsumerWidget {
  const _DetailsCta({
    required this.summary,
    required this.libraryEntry,
    required this.franchiseEntries,
  });

  final AnimeSummary summary;
  final LibraryEntry? libraryEntry;
  final List<FranchiseEntry> franchiseEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = libraryEntry;
    if (entry == null) {
      return FilledButton(
        onPressed: () {
          _setStatusWithUndo(
            context: context,
            ref: ref,
            anime: summary,
            status: LibraryStatus.planned,
            previousEntry: null,
          );
        },
        child: const Text('Добавить'),
      );
    }

    return switch (entry.status) {
      LibraryStatus.planned => FilledButton(
        onPressed: () {
          _setStatusWithUndo(
            context: context,
            ref: ref,
            anime: summary,
            status: LibraryStatus.watching,
            previousEntry: entry,
          );
        },
        child: const Text('Начать смотреть'),
      ),
      LibraryStatus.watching => const FilledButton.tonal(
        onPressed: null,
        child: Text('Продолжить'),
      ),
      LibraryStatus.completed => _FranchiseCta(
        currentAnimeId: summary.id,
        franchiseEntries: franchiseEntries,
      ),
      LibraryStatus.postponed => OutlinedButton(
        onPressed: () {
          _setStatusWithUndo(
            context: context,
            ref: ref,
            anime: summary,
            status: LibraryStatus.watching,
            previousEntry: entry,
          );
        },
        child: const Text('Вернуть в просмотр'),
      ),
      LibraryStatus.dropped => const OutlinedButton(
        onPressed: null,
        child: Text('В библиотеке'),
      ),
    };
  }
}

class _FranchiseCta extends StatelessWidget {
  const _FranchiseCta({
    required this.currentAnimeId,
    required this.franchiseEntries,
  });

  final String currentAnimeId;
  final List<FranchiseEntry> franchiseEntries;

  @override
  Widget build(BuildContext context) {
    final target = _firstOtherFranchiseEntry(franchiseEntries, currentAnimeId);

    return FilledButton.tonal(
      onPressed: target == null
          ? null
          : () {
              context.push(AppRoutes.animeDetails(_routeId(target.summary)));
            },
      child: const Text('Открыть франшизу'),
    );
  }
}

FranchiseEntry? _firstOtherFranchiseEntry(
  List<FranchiseEntry> entries,
  String currentAnimeId,
) {
  for (final entry in entries) {
    if (entry.releaseId != currentAnimeId) {
      return entry;
    }
  }

  return null;
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.details, required this.progress});

  final AnimeDetails details;
  final WatchProgress? progress;

  @override
  Widget build(BuildContext context) {
    final summary = details.summary;
    final metadata = [
      if (details.genres.isNotEmpty) details.genres.join(', '),
      episodesProgressLabel(summary.episodesTotal, progress),
      if (summary.publishDay != null) publishDayLabel(summary.publishDay),
      if (details.averageEpisodeDurationSec != null)
        '${(details.averageEpisodeDurationSec ?? 0) ~/ 60} мин',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in metadata)
          if (item != null && item.isNotEmpty) AppInfoChip(label: item),
      ],
    );
  }
}

class _BlockedContentBanner extends StatelessWidget {
  const _BlockedContentBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Контент может быть недоступен в вашем регионе',
                style: TextStyle(color: colorScheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  final String? description;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = description?.trim();
    if (text == null || text.isEmpty) {
      return const _SectionText(
        title: 'Описание',
        text: 'Описание пока недоступно',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Описание', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          text,
          maxLines: expanded ? null : 5,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(expanded ? 'Свернуть' : 'Показать полностью'),
        ),
      ],
    );
  }
}

class _FranchiseSection extends StatelessWidget {
  const _FranchiseSection({
    required this.currentAnimeId,
    required this.entries,
    required this.libraryOverlay,
  });

  final String currentAnimeId;
  final List<FranchiseEntry> entries;
  final Map<String, LibraryEntry> libraryOverlay;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _SectionText(
        title: 'Связанное',
        text: 'Связанные тайтлы не найдены',
      );
    }

    if (entries.length == 1 && entries.single.releaseId == currentAnimeId) {
      return const _SectionText(
        title: 'Франшиза',
        text: 'Других тайтлов во франшизе пока нет',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Франшиза', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final entry in entries) ...[
          _FranchiseTile(
            entry: entry,
            isCurrent: entry.releaseId == currentAnimeId,
            libraryEntry: libraryOverlay[entry.releaseId],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _FranchiseTile extends StatelessWidget {
  const _FranchiseTile({
    required this.entry,
    required this.isCurrent,
    required this.libraryEntry,
  });

  final FranchiseEntry entry;
  final bool isCurrent;
  final LibraryEntry? libraryEntry;

  @override
  Widget build(BuildContext context) {
    final localEntry = libraryEntry;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 44,
        child: AnimePosterImage(
          imageUrl: entry.summary.posterUrl,
          semanticLabel: entry.summary.title,
        ),
      ),
      title: Text(
        entry.summary.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (entry.sortOrder != null)
            AppInfoChip(label: 'Порядок: ${entry.sortOrder}'),
          if (entry.summary.year != null)
            AppInfoChip(label: entry.summary.year.toString()),
          if (localEntry != null)
            LibraryStatusChip(
              status: localEntry.status,
              isFavorite: localEntry.isFavorite,
            ),
          if (isCurrent) const AppInfoChip(label: 'Открыто сейчас'),
        ],
      ),
      onTap: isCurrent
          ? null
          : () {
              context.push(AppRoutes.animeDetails(_routeId(entry.summary)));
            },
    );
  }
}

class _AdditionalSection extends StatelessWidget {
  const _AdditionalSection({required this.details});

  final AnimeDetails details;

  @override
  Widget build(BuildContext context) {
    final updatedAt = details.summary.updatedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Дополнительно', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (details.membersCount != null)
          Text('Участников озвучки: ${details.membersCount}'),
        if (updatedAt != null) Text('Обновлено: ${dateLabel(updatedAt)}'),
        Text('ID релиза: ${details.summary.id}'),
      ],
    );
  }
}

class _SectionText extends StatelessWidget {
  const _SectionText({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(text),
      ],
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 130, child: AnimePosterImage()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: double.infinity, color: color),
                  const SizedBox(height: 10),
                  _SkeletonBlock(width: 160, color: color),
                  const SizedBox(height: 10),
                  _SkeletonBlock(width: 220, color: color),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SkeletonBlock(width: double.infinity, height: 96, color: color),
      ],
    );
  }
}

class _FranchiseSkeleton extends StatelessWidget {
  const _FranchiseSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBlock(width: 120, color: color),
        const SizedBox(height: 8),
        _SkeletonBlock(width: double.infinity, height: 56, color: color),
        const SizedBox(height: 8),
        _SkeletonBlock(width: double.infinity, height: 56, color: color),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.color,
    this.height = 18,
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

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        text: message,
        actionLabel: 'Повторить',
        onAction: onRetry,
        padding: const EdgeInsets.all(24),
      ),
    );
  }
}

String _routeId(AnimeSummary anime) {
  return anime.alias.isEmpty ? anime.id : anime.alias;
}

Future<void> _setStatusWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required AnimeSummary anime,
  required LibraryStatus status,
  required LibraryEntry? previousEntry,
}) async {
  if (previousEntry?.status == status) {
    return;
  }

  final actions = ref.read(animeDetailsActionsProvider);
  try {
    await actions.setStatus(anime, status);
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
      if (previousEntry == null) {
        actions.removeFromLibrary(anime.id);
        return;
      }

      actions.setStatus(anime, previousEntry.status);
    },
  );
}

Future<void> _toggleFavoriteWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required AnimeSummary anime,
}) async {
  final actions = ref.read(animeDetailsActionsProvider);
  try {
    await actions.toggleFavorite(anime);
  } catch (error) {
    if (context.mounted) {
      showActionErrorSnackBar(context, 'Не удалось обновить избранное');
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  showUndoSnackBar(
    context,
    message: 'Избранное обновлено',
    onUndo: () {
      actions.toggleFavorite(anime);
    },
  );
}

String _errorMessage(Object error) {
  return switch (error) {
    NetworkError() => 'Не удалось загрузить детали',
    NotFoundError() => 'Тайтл не найден',
    ParseError() => 'Не удалось прочитать данные тайтла',
    CacheError() => 'Не удалось прочитать локальные данные',
    UnknownError() => 'Что-то пошло не так',
    _ => 'Что-то пошло не так',
  };
}

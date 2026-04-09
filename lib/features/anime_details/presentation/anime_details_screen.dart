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
import '../../../shared/widgets/anime_poster_image.dart';
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
          error: (error, stackTrace) =>
              _DetailsError(message: _errorMessage(error)),
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
                  _InfoChip(label: _typeLabel(summary.type)),
                  if (summary.year != null)
                    _InfoChip(label: summary.year.toString()),
                  if (summary.season != null)
                    _InfoChip(label: _seasonLabel(summary.season)),
                  if (summary.ageRating != null)
                    _InfoChip(label: _ageRatingLabel(summary.ageRating)),
                  if (summary.isOngoing) const _InfoChip(label: 'Онгоинг'),
                  _InfoChip(label: '♥ ${summary.favoritesCount}'),
                  if (libraryEntry != null)
                    _InfoChip(label: _statusLabel(libraryEntry?.status)),
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
                              animeId: summary.id,
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
                        animeId: summary.id,
                        status: status,
                        previousEntry: libraryEntry,
                      );
                    },
                    itemBuilder: (context) => [
                      for (final status in LibraryStatus.values)
                        PopupMenuItem(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                    ],
                  ),
                ],
              ),
              if (progressValue != null)
                Text(
                  _progressLabel(progressValue, summary.episodesTotal),
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
            animeId: summary.id,
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
            animeId: summary.id,
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
            animeId: summary.id,
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
      _episodesLabel(summary.episodesTotal, progress),
      if (summary.publishDay != null) _publishDayLabel(summary.publishDay),
      if (details.averageEpisodeDurationSec != null)
        '${(details.averageEpisodeDurationSec ?? 0) ~/ 60} мин',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in metadata)
          if (item != null && item.isNotEmpty) _InfoChip(label: item),
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
          if (entry.sortOrder != null) Text('Порядок: ${entry.sortOrder}'),
          if (entry.summary.year != null) Text(entry.summary.year.toString()),
          if (libraryEntry != null) Text(_statusLabel(libraryEntry?.status)),
          if (isCurrent) const Text('Открыто сейчас'),
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
        if (updatedAt != null) Text('Обновлено: ${_dateLabel(updatedAt)}'),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
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
  const _DetailsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

String? _episodesLabel(int? total, WatchProgress? progress) {
  final watched = progress?.watchedEpisodes;
  if (watched != null && total != null) {
    return 'Прогресс: $watched/$total';
  }
  if (watched != null) {
    return 'Просмотрено: $watched';
  }
  if (total != null) {
    return 'Эпизодов: $total';
  }
  return null;
}

String _progressLabel(WatchProgress progress, int? total) {
  if (total == null) {
    return 'Просмотрено: ${progress.watchedEpisodes}';
  }

  return 'Прогресс: ${progress.watchedEpisodes}/$total';
}

String _routeId(AnimeSummary anime) {
  return anime.alias.isEmpty ? anime.id : anime.alias;
}

String _typeLabel(AnimeType type) {
  return switch (type) {
    AnimeType.tv => 'ТВ',
    AnimeType.movie => 'Фильм',
    AnimeType.ova => 'OVA',
    AnimeType.ona => 'ONA',
    AnimeType.special => 'Спешл',
    AnimeType.unknown => 'Тип неизвестен',
  };
}

String _seasonLabel(AnimeSeason? season) {
  return switch (season) {
    AnimeSeason.winter => 'Зима',
    AnimeSeason.spring => 'Весна',
    AnimeSeason.summer => 'Лето',
    AnimeSeason.fall => 'Осень',
    null => '',
  };
}

String _publishDayLabel(PublishDay? day) {
  return switch (day) {
    PublishDay.monday => 'Понедельник',
    PublishDay.tuesday => 'Вторник',
    PublishDay.wednesday => 'Среда',
    PublishDay.thursday => 'Четверг',
    PublishDay.friday => 'Пятница',
    PublishDay.saturday => 'Суббота',
    PublishDay.sunday => 'Воскресенье',
    null => '',
  };
}

String _ageRatingLabel(AgeRating? rating) {
  return switch (rating) {
    AgeRating.g => '0+',
    AgeRating.pg => '6+',
    AgeRating.pg13 => '12+',
    AgeRating.r => '16+',
    AgeRating.rPlus => '18+',
    AgeRating.rx => '18+',
    AgeRating.unknown => 'Возраст неизвестен',
    null => '',
  };
}

String _statusLabel(LibraryStatus? status) {
  return switch (status) {
    LibraryStatus.watching => 'Смотрю',
    LibraryStatus.planned => 'Хочу посмотреть',
    LibraryStatus.completed => 'Просмотрено',
    LibraryStatus.postponed => 'Отложено',
    LibraryStatus.dropped => 'Брошено',
    null => '',
  };
}

String _dateLabel(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

Future<void> _setStatusWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required String animeId,
  required LibraryStatus status,
  required LibraryEntry? previousEntry,
}) async {
  final actions = ref.read(animeDetailsActionsProvider);
  await actions.setStatus(animeId, status);

  if (!context.mounted) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      content: Text('Статус: ${_statusLabel(status)}'),
      action: SnackBarAction(
        label: 'Отменить',
        onPressed: () {
          if (previousEntry == null) {
            actions.removeFromLibrary(animeId);
            return;
          }

          actions.setStatus(animeId, previousEntry.status);
        },
      ),
    ),
  );
}

Future<void> _toggleFavoriteWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required String animeId,
}) async {
  final actions = ref.read(animeDetailsActionsProvider);
  await actions.toggleFavorite(animeId);

  if (!context.mounted) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      content: const Text('Избранное обновлено'),
      action: SnackBarAction(
        label: 'Отменить',
        onPressed: () {
          actions.toggleFavorite(animeId);
        },
      ),
    ),
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

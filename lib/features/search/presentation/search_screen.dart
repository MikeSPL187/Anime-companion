import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/error/app_error.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/anime_summary.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/search_history_entry.dart';
import '../../../shared/utils/anime_labels.dart';
import '../../../shared/widgets/action_feedback.dart';
import '../../../shared/widgets/anime_poster_image.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/presentation_chips.dart';
import '../application/search_providers.dart';
import '../domain/search_browse_slice.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final libraryOverlay = ref.watch(searchLibraryOverlayProvider).value ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Поиск')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SearchField(
              controller: _searchController,
              onSubmitted: _submitQuery,
              onClear: () => _submitQuery(''),
            ),
            const SizedBox(height: 16),
            if (query.isEmpty) ...[
              const _RecentSearchesSection(),
              const SizedBox(height: 20),
              _BrowseSection(
                title: 'Новое',
                slice: SearchBrowseSlice.latest,
                libraryOverlay: libraryOverlay,
              ),
              const SizedBox(height: 20),
              _BrowseSection(
                title: 'Онгоинги',
                slice: SearchBrowseSlice.ongoing,
                libraryOverlay: libraryOverlay,
              ),
            ] else
              _SearchResultsSection(
                query: query,
                libraryOverlay: libraryOverlay,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuery(String query) async {
    _searchController.text = query.trim();
    await ref.read(searchActionsProvider).submitQuery(query);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final Future<void> Function(String query) onSubmitted;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) async {
        await onSubmitted(value);
      },
      decoration: InputDecoration(
        hintText: 'Название аниме',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          tooltip: 'Очистить',
          onPressed: () async {
            await onClear();
          },
          icon: const Icon(Icons.clear),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _RecentSearchesSection extends ConsumerWidget {
  const _RecentSearchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(recentSearchesProvider);

    return recentSearches.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Недавние запросы',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(searchActionsProvider).clearRecentQueries();
                  },
                  child: const Text('Очистить'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in entries)
                  _RecentSearchChip(searchHistoryEntry: entry),
              ],
            ),
          ],
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const _ChipSkeletonRow(),
    );
  }
}

class _RecentSearchChip extends ConsumerWidget {
  const _RecentSearchChip({required this.searchHistoryEntry});

  final SearchHistoryEntry searchHistoryEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InputChip(
      label: Text(searchHistoryEntry.query),
      onPressed: () {
        ref.read(searchActionsProvider).submitQuery(searchHistoryEntry.query);
      },
      onDeleted: () {
        ref
            .read(searchActionsProvider)
            .removeRecentQuery(searchHistoryEntry.query);
      },
    );
  }
}

class _SearchResultsSection extends ConsumerWidget {
  const _SearchResultsSection({
    required this.query,
    required this.libraryOverlay,
  });

  final String query;
  final Map<String, LibraryEntry> libraryOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      data: (page) {
        if (page.items.isEmpty) {
          return _EmptyState(text: 'Ничего не найдено по запросу «$query»');
        }

        return _AnimeResultList(
          items: page.items,
          libraryOverlay: libraryOverlay,
        );
      },
      error: (error, stackTrace) => _ErrorState(
        message: _errorMessage(error),
        onRetry: () {
          ref.invalidate(searchResultsProvider);
        },
      ),
      loading: () => const _ResultSkeletonList(),
    );
  }
}

class _BrowseSection extends ConsumerWidget {
  const _BrowseSection({
    required this.title,
    required this.slice,
    required this.libraryOverlay,
  });

  final String title;
  final SearchBrowseSlice slice;
  final Map<String, LibraryEntry> libraryOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchBrowseResultsProvider(slice));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        results.when(
          data: (page) {
            if (page.items.isEmpty) {
              return const _EmptyState(text: 'Здесь пока пусто');
            }

            return _AnimeResultList(
              items: page.items.take(6).toList(),
              libraryOverlay: libraryOverlay,
            );
          },
          error: (error, stackTrace) => _ErrorState(
            message: _errorMessage(error),
            onRetry: () {
              ref.invalidate(searchBrowseResultsProvider(slice));
            },
          ),
          loading: () => const _ResultSkeletonList(itemCount: 3),
        ),
      ],
    );
  }
}

class _AnimeResultList extends StatelessWidget {
  const _AnimeResultList({required this.items, required this.libraryOverlay});

  final List<AnimeSummary> items;
  final Map<String, LibraryEntry> libraryOverlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          _AnimeResultCard(anime: item, libraryEntry: libraryOverlay[item.id]),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AnimeResultCard extends ConsumerWidget {
  const _AnimeResultCard({required this.anime, required this.libraryEntry});

  final AnimeSummary anime;
  final LibraryEntry? libraryEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => context.push(AppRoutes.animeDetails(_routeId(anime))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 84,
                child: AnimePosterImage(
                  imageUrl: anime.posterUrl,
                  semanticLabel: anime.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _AnimeResultInfo(anime: anime)),
              const SizedBox(width: 8),
              _StatusAction(anime: anime, libraryEntry: libraryEntry),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimeResultInfo extends StatelessWidget {
  const _AnimeResultInfo({required this.anime});

  final AnimeSummary anime;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          anime.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall,
        ),
        if (anime.altTitle != null) ...[
          const SizedBox(height: 2),
          Text(
            anime.altTitle ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppInfoChip(label: animeTypeLabel(anime.type)),
            if (anime.year != null) AppInfoChip(label: anime.year.toString()),
            AppInfoChip(label: popularityLabel(anime.favoritesCount)),
            if (anime.isOngoing) const AppInfoChip(label: 'Онгоинг'),
          ],
        ),
      ],
    );
  }
}

class _StatusAction extends ConsumerWidget {
  const _StatusAction({required this.anime, required this.libraryEntry});

  final AnimeSummary anime;
  final LibraryEntry? libraryEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = libraryEntry;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (entry != null)
          _StatusChip(libraryEntry: entry)
        else
          FilledButton.tonal(
            onPressed: () {
              _setStatus(context, ref, LibraryStatus.planned);
            },
            child: const Text('Добавить'),
          ),
        PopupMenuButton<LibraryStatus>(
          tooltip: 'Изменить статус',
          onSelected: (status) => _setStatus(context, ref, status),
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

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    LibraryStatus status,
  ) async {
    final previousEntry = libraryEntry;
    if (previousEntry?.status == status) {
      return;
    }

    try {
      await ref.read(catalogEntryActionsProvider).setStatus(anime, status);
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
        final actions = ref.read(catalogEntryActionsProvider);
        if (previousEntry == null) {
          actions.removeFromLibrary(anime.id);
        } else {
          actions.setStatus(anime, previousEntry.status);
        }
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.libraryEntry});

  final LibraryEntry libraryEntry;

  @override
  Widget build(BuildContext context) {
    return LibraryStatusChip(
      status: libraryEntry.status,
      isFavorite: libraryEntry.isFavorite,
    );
  }
}

class _ResultSkeletonList extends StatelessWidget {
  const _ResultSkeletonList({this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      children: [
        for (var index = 0; index < itemCount; index += 1) ...[
          Row(
            children: [
              const SizedBox(width: 84, child: AnimePosterImage()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBlock(width: double.infinity, color: color),
                    const SizedBox(height: 8),
                    _SkeletonBlock(width: 140, color: color),
                    const SizedBox(height: 8),
                    _SkeletonBlock(width: 220, color: color),
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

class _ChipSkeletonRow extends StatelessWidget {
  const _ChipSkeletonRow();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SkeletonBlock(width: 96, height: 32, color: color),
        _SkeletonBlock(width: 128, height: 32, color: color),
        _SkeletonBlock(width: 112, height: 32, color: color),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(text: text);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      text: message,
      actionLabel: 'Повторить',
      onAction: onRetry,
    );
  }
}

String _routeId(AnimeSummary anime) {
  return anime.alias.isEmpty ? anime.id : anime.alias;
}

String _errorMessage(Object error) {
  return switch (error) {
    NetworkError() => 'Не удалось загрузить каталог',
    NotFoundError() => 'Ничего не найдено',
    ParseError() => 'Не удалось прочитать данные каталога',
    CacheError() => 'Не удалось прочитать локальные данные',
    UnknownError() => 'Что-то пошло не так',
    _ => 'Что-то пошло не так',
  };
}

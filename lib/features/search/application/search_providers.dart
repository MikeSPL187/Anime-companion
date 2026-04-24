import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_result.dart';
import '../../../data/providers/catalog_repository_provider.dart';
import '../../../data/providers/local_repository_providers.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/anime_summary.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../domain/models/search_history_entry.dart';
import '../domain/search_browse_slice.dart';

final searchQueryProvider = NotifierProvider.autoDispose<SearchQuery, String>(
  SearchQuery.new,
);

final searchResultsProvider =
    FutureProvider.autoDispose<PaginatedResult<AnimeSummary>>((ref) {
      final query = ref.watch(searchQueryProvider).trim();
      if (query.isEmpty) {
        return Future.value(
          const PaginatedResult(items: [], page: 1, hasNextPage: false),
        );
      }

      return ref.watch(catalogRepositoryProvider).search(query);
    });

final searchBrowseResultsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<AnimeSummary>, SearchBrowseSlice>((ref, slice) {
      final repository = ref.watch(catalogRepositoryProvider);

      return switch (slice) {
        SearchBrowseSlice.latest => repository.getLatest(),
        SearchBrowseSlice.ongoing => repository.getOngoing(),
      };
    });

final recentSearchesProvider =
    FutureProvider.autoDispose<List<SearchHistoryEntry>>((ref) {
      return ref.watch(searchHistoryRepositoryProvider).getRecent();
    });

final searchLibraryOverlayProvider =
    StreamProvider.autoDispose<Map<String, LibraryEntry>>((ref) {
      return ref.watch(libraryRepositoryProvider).watchAll().map((entries) {
        return {for (final entry in entries) entry.animeId: entry};
      });
    });

final searchActionsProvider = Provider.autoDispose<SearchActions>((ref) {
  return SearchActions(ref);
});

final catalogEntryActionsProvider = Provider.autoDispose<CatalogEntryActions>((
  ref,
) {
  return CatalogEntryActions(ref);
});

class SearchActions {
  const SearchActions(this._ref);

  final Ref _ref;

  Future<void> submitQuery(String query) async {
    final normalizedQuery = query.trim();
    _ref.read(searchQueryProvider.notifier).setQuery(normalizedQuery);

    if (normalizedQuery.isEmpty) {
      return;
    }

    await _ref.read(searchHistoryRepositoryProvider).saveQuery(normalizedQuery);
    _ref.invalidate(recentSearchesProvider);
  }

  Future<void> removeRecentQuery(String query) async {
    await _ref.read(searchHistoryRepositoryProvider).removeQuery(query);
    _ref.invalidate(recentSearchesProvider);
  }

  Future<void> clearRecentQueries() async {
    await _ref.read(searchHistoryRepositoryProvider).clearAll();
    _ref.invalidate(recentSearchesProvider);
  }
}

class SearchQuery extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}

class CatalogEntryActions {
  const CatalogEntryActions(this._ref);

  final Ref _ref;

  Future<void> setStatus(AnimeSummary anime, LibraryStatus status) {
    return _ref
        .read(libraryRepositoryProvider)
        .setStatus(
          anime.id,
          status,
          snapshot: LibraryPresentationSnapshot.fromAnimeSummary(anime),
        );
  }

  Future<void> removeFromLibrary(String animeId) {
    return _ref.read(libraryRepositoryProvider).removeFromLibrary(animeId);
  }
}

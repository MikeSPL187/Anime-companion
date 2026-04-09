import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/catalog_repository_provider.dart';
import '../../../data/providers/franchise_repository_provider.dart';
import '../../../data/providers/local_repository_providers.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/anime_details.dart';
import '../../../domain/models/anime_summary.dart';
import '../../../domain/models/franchise_entry.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../domain/models/watch_progress.dart';

final animeDetailsProvider = FutureProvider.autoDispose
    .family<AnimeDetails, String>((ref, idOrAlias) {
      return ref.watch(catalogRepositoryProvider).getByIdOrAlias(idOrAlias);
    });

final animeFranchiseProvider = FutureProvider.autoDispose
    .family<List<FranchiseEntry>, String>((ref, releaseId) {
      return ref.watch(franchiseRepositoryProvider).getByReleaseId(releaseId);
    });

final detailsLibraryEntryProvider = StreamProvider.autoDispose
    .family<LibraryEntry?, String>((ref, animeId) {
      return ref.watch(libraryRepositoryProvider).watchAll().map((entries) {
        for (final entry in entries) {
          if (entry.animeId == animeId) {
            return entry;
          }
        }
        return null;
      });
    });

final detailsProgressProvider = StreamProvider.autoDispose
    .family<WatchProgress?, String>((ref, animeId) {
      return ref.watch(progressRepositoryProvider).watchProgress(animeId);
    });

final detailsLibraryOverlayProvider =
    StreamProvider.autoDispose<Map<String, LibraryEntry>>((ref) {
      return ref.watch(libraryRepositoryProvider).watchAll().map((entries) {
        return {for (final entry in entries) entry.animeId: entry};
      });
    });

final animeDetailsActionsProvider = Provider.autoDispose<AnimeDetailsActions>((
  ref,
) {
  return AnimeDetailsActions(ref);
});

class AnimeDetailsActions {
  const AnimeDetailsActions(this._ref);

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

  Future<void> toggleFavorite(AnimeSummary anime) {
    return _ref
        .read(libraryRepositoryProvider)
        .toggleFavorite(
          anime.id,
          snapshot: LibraryPresentationSnapshot.fromAnimeSummary(anime),
        );
  }

  Future<void> removeFromLibrary(String animeId) {
    return _ref.read(libraryRepositoryProvider).removeFromLibrary(animeId);
  }
}

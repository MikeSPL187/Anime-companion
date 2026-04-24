import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/local_repository_providers.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../domain/models/watch_progress.dart';

final librarySelectedStatusProvider =
    NotifierProvider.autoDispose<LibrarySelectedStatus, LibraryStatus>(
      LibrarySelectedStatus.new,
    );

final libraryFilterProvider =
    NotifierProvider.autoDispose<LibraryFilter, String>(LibraryFilter.new);

final libraryEntriesProvider = StreamProvider.autoDispose<List<LibraryEntry>>((
  ref,
) {
  return ref.watch(libraryRepositoryProvider).watchAll();
});

final librarySnapshotsProvider =
    StreamProvider.autoDispose<Map<String, LibraryPresentationSnapshot>>((ref) {
      return ref
          .watch(libraryPresentationSnapshotRepositoryProvider)
          .watchAll();
    });

final libraryFilteredEntriesProvider =
    Provider.autoDispose<AsyncValue<List<LibraryListItem>>>((ref) {
      final selectedStatus = ref.watch(librarySelectedStatusProvider);
      final filter = ref.watch(libraryFilterProvider).trim().toLowerCase();
      final entries = ref.watch(libraryEntriesProvider);
      final snapshots = ref.watch(librarySnapshotsProvider).value ?? {};

      return entries.whenData((items) {
        return items
            .map((entry) {
              return LibraryListItem(
                entry: entry,
                snapshot: snapshots[entry.animeId],
              );
            })
            .where((item) {
              final entry = item.entry;
              if (entry.status != selectedStatus) {
                return false;
              }

              if (filter.isEmpty) {
                return true;
              }

              return _matchesLibraryFilter(item, filter);
            })
            .toList();
      });
    });

final librarySegmentCountsProvider =
    Provider.autoDispose<AsyncValue<Map<LibraryStatus, int>>>((ref) {
      final entries = ref.watch(libraryEntriesProvider);

      return entries.whenData((items) {
        return {
          for (final status in LibraryStatus.values)
            status: items.where((entry) => entry.status == status).length,
        };
      });
    });

final libraryProgressProvider = StreamProvider.autoDispose
    .family<WatchProgress?, String>((ref, animeId) {
      return ref.watch(progressRepositoryProvider).watchProgress(animeId);
    });

final libraryActionsProvider = Provider.autoDispose<LibraryActions>((ref) {
  return LibraryActions(ref);
});

class LibrarySelectedStatus extends Notifier<LibraryStatus> {
  @override
  LibraryStatus build() {
    return LibraryStatus.watching;
  }

  void setStatus(LibraryStatus status) {
    state = status;
  }
}

class LibraryFilter extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setFilter(String filter) {
    state = filter;
  }

  void clear() {
    state = '';
  }
}

class LibraryListItem {
  const LibraryListItem({required this.entry, required this.snapshot});

  final LibraryEntry entry;
  final LibraryPresentationSnapshot? snapshot;
}

class LibraryActions {
  const LibraryActions(this._ref);

  final Ref _ref;

  Future<void> setStatus(String animeId, LibraryStatus status) {
    return _ref.read(libraryRepositoryProvider).setStatus(animeId, status);
  }

  Future<void> incrementEpisode(String animeId, {int? episodesTotal}) {
    return _ref
        .read(progressRepositoryProvider)
        .incrementEpisode(animeId, episodesTotal: episodesTotal);
  }

  Future<void> restoreProgress({
    required String animeId,
    required bool existedBefore,
    required int watchedEpisodes,
  }) {
    if (!existedBefore) {
      return _ref.read(progressRepositoryProvider).clearProgress(animeId);
    }

    return _ref
        .read(progressRepositoryProvider)
        .setEpisode(animeId, watchedEpisodes);
  }
}

bool _matchesLibraryFilter(LibraryListItem item, String filter) {
  final entry = item.entry;
  final snapshot = item.snapshot;

  return entry.animeId.toLowerCase().contains(filter) ||
      (entry.note?.toLowerCase().contains(filter) ?? false) ||
      (snapshot?.title.toLowerCase().contains(filter) ?? false) ||
      (snapshot?.altTitle?.toLowerCase().contains(filter) ?? false);
}

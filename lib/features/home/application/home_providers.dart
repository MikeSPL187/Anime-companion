import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../data/providers/local_repository_providers.dart';
import '../../../data/providers/schedule_repository_provider.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../domain/models/schedule_item.dart';
import '../../../domain/models/watch_progress.dart';

const int _continueLimit = 5;
const int _schedulePreviewLimit = 5;
const int _whatNextLimit = 4;
const int _plannedAttentionAgeDays = 7;

final homeNowProvider = Provider.autoDispose<DateTime>((ref) {
  return DateTime.now();
});

final homeLibraryEntriesProvider =
    StreamProvider.autoDispose<List<LibraryEntry>>((ref) {
      return ref.watch(libraryRepositoryProvider).watchAll();
    });

final homeSnapshotsProvider =
    StreamProvider.autoDispose<Map<String, LibraryPresentationSnapshot>>((ref) {
      return ref
          .watch(libraryPresentationSnapshotRepositoryProvider)
          .watchAll();
    });

final homeProgressProvider = StreamProvider.autoDispose
    .family<WatchProgress?, String>((ref, animeId) {
      return ref.watch(progressRepositoryProvider).watchProgress(animeId);
    });

final homeContinueItemsProvider =
    Provider.autoDispose<AsyncValue<List<HomeLibraryItem>>>((ref) {
      final entries = ref.watch(homeLibraryEntriesProvider);
      final snapshots = ref.watch(homeSnapshotsProvider).value ?? {};

      return entries.whenData((items) {
        return items
            .where((entry) => entry.status == LibraryStatus.watching)
            .map((entry) {
              return HomeLibraryItem(
                entry: entry,
                snapshot: snapshots[entry.animeId],
              );
            })
            .take(_continueLimit)
            .toList();
      });
    });

final homeWhatNextItemsProvider =
    Provider.autoDispose<AsyncValue<List<HomeLibraryItem>>>((ref) {
      final entries = ref.watch(homeLibraryEntriesProvider);
      final snapshots = ref.watch(homeSnapshotsProvider).value ?? {};
      final cutoff = ref
          .watch(homeNowProvider)
          .subtract(const Duration(days: _plannedAttentionAgeDays));

      return entries.whenData((items) {
        final plannedItems =
            items.where((entry) {
              return entry.status == LibraryStatus.planned &&
                  entry.lastInteractedAt.isBefore(cutoff);
            }).toList()..sort(
              (left, right) =>
                  left.lastInteractedAt.compareTo(right.lastInteractedAt),
            );

        return plannedItems
            .map((entry) {
              return HomeLibraryItem(
                entry: entry,
                snapshot: snapshots[entry.animeId],
              );
            })
            .take(_whatNextLimit)
            .toList();
      });
    });

final homeSchedulePreviewProvider =
    FutureProvider.autoDispose<HomeSchedulePreview>((ref) async {
      final now = ref.watch(homeNowProvider);
      final entries = await ref.watch(homeLibraryEntriesProvider.future);
      final snapshots = await ref.watch(homeSnapshotsProvider.future);
      final repository = ref.watch(scheduleRepositoryProvider);
      final schedule = await repository.getWeek();
      final fetchedAt = await repository.lastFetchedAt(
        CacheScopes.scheduleWeek,
      );
      final personalEntries = _personalScheduleEntries(entries);
      final previewItems = _schedulePreviewItems(
        schedule: schedule,
        entries: personalEntries,
        snapshots: snapshots,
        now: now,
      );

      return HomeSchedulePreview(items: previewItems, fetchedAt: fetchedAt);
    });

final homeActionsProvider = Provider.autoDispose<HomeActions>((ref) {
  return HomeActions(ref);
});

class HomeLibraryItem {
  const HomeLibraryItem({required this.entry, required this.snapshot});

  final LibraryEntry entry;
  final LibraryPresentationSnapshot? snapshot;
}

class HomeSchedulePreview {
  const HomeSchedulePreview({required this.items, required this.fetchedAt});

  final List<HomeSchedulePreviewItem> items;
  final DateTime? fetchedAt;
}

class HomeSchedulePreviewItem {
  const HomeSchedulePreviewItem({
    required this.scheduleItem,
    required this.entry,
    required this.snapshot,
    required this.priority,
  });

  final ScheduleItem scheduleItem;
  final LibraryEntry entry;
  final LibraryPresentationSnapshot? snapshot;
  final HomeSchedulePriority priority;
}

enum HomeSchedulePriority { watching, favorite }

class HomeActions {
  const HomeActions(this._ref);

  final Ref _ref;

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

Map<String, LibraryEntry> _personalScheduleEntries(List<LibraryEntry> entries) {
  return {
    for (final entry in entries)
      if (_isPersonalScheduleEntry(entry)) entry.animeId: entry,
  };
}

bool _isPersonalScheduleEntry(LibraryEntry entry) {
  return entry.status == LibraryStatus.watching ||
      (entry.isFavorite && entry.status != LibraryStatus.dropped);
}

List<HomeSchedulePreviewItem> _schedulePreviewItems({
  required List<ScheduleItem> schedule,
  required Map<String, LibraryEntry> entries,
  required Map<String, LibraryPresentationSnapshot> snapshots,
  required DateTime now,
}) {
  final items = <HomeSchedulePreviewItem>[];

  for (final scheduleItem in schedule) {
    final entry = entries[scheduleItem.releaseId];
    if (entry == null) {
      continue;
    }

    items.add(
      HomeSchedulePreviewItem(
        scheduleItem: scheduleItem,
        entry: entry,
        snapshot: snapshots[scheduleItem.releaseId],
        priority: entry.status == LibraryStatus.watching
            ? HomeSchedulePriority.watching
            : HomeSchedulePriority.favorite,
      ),
    );
  }

  items.sort(
    (left, right) => _compareSchedulePreviewItems(left, right, now: now),
  );
  return items.take(_schedulePreviewLimit).toList();
}

int _compareSchedulePreviewItems(
  HomeSchedulePreviewItem left,
  HomeSchedulePreviewItem right, {
  required DateTime now,
}) {
  final priorityComparison = left.priority.index.compareTo(
    right.priority.index,
  );
  if (priorityComparison != 0) {
    return priorityComparison;
  }

  return _daysUntil(
    left.scheduleItem.publishDay,
    now,
  ).compareTo(_daysUntil(right.scheduleItem.publishDay, now));
}

int _daysUntil(PublishDay publishDay, DateTime now) {
  final today = now.weekday;
  final targetDay = publishDay.index + 1;
  return (targetDay - today) % DateTime.daysPerWeek;
}

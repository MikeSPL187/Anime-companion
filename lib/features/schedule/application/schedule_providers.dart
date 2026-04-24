import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_policy.dart';
import '../../../data/providers/local_repository_providers.dart';
import '../../../data/providers/schedule_repository_provider.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/library_entry.dart';
import '../../../domain/models/library_presentation_snapshot.dart';
import '../../../domain/models/schedule_item.dart';

final scheduleNowProvider = Provider.autoDispose<DateTime>((ref) {
  return DateTime.now();
});

final scheduleLibraryEntriesProvider =
    StreamProvider.autoDispose<List<LibraryEntry>>((ref) {
      return ref.watch(libraryRepositoryProvider).watchAll();
    });

final scheduleSnapshotsProvider =
    StreamProvider.autoDispose<Map<String, LibraryPresentationSnapshot>>((ref) {
      return ref
          .watch(libraryPresentationSnapshotRepositoryProvider)
          .watchAll();
    });

final scheduleScreenStateProvider =
    FutureProvider.autoDispose<ScheduleScreenState>((ref) async {
      final now = ref.watch(scheduleNowProvider);
      final entries = await ref.watch(scheduleLibraryEntriesProvider.future);
      final snapshots = await ref.watch(scheduleSnapshotsProvider.future);
      final repository = ref.watch(scheduleRepositoryProvider);
      final schedule = await repository.getWeek();
      final fetchedAt = await repository.lastFetchedAt(
        CacheScopes.scheduleWeek,
      );
      final personalEntries = _personalScheduleEntries(entries);

      return ScheduleScreenState(
        groups: _groupScheduleItems(
          schedule: schedule,
          entries: personalEntries,
          snapshots: snapshots,
          now: now,
        ),
        fetchedAt: fetchedAt,
        isStale: _isStale(fetchedAt, now),
        hasPersonalEntries: personalEntries.isNotEmpty,
      );
    });

final scheduleRefreshControllerProvider =
    NotifierProvider.autoDispose<
      ScheduleRefreshController,
      ScheduleRefreshState
    >(ScheduleRefreshController.new);

class ScheduleRefreshController extends Notifier<ScheduleRefreshState> {
  @override
  ScheduleRefreshState build() {
    return const ScheduleRefreshState();
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = const ScheduleRefreshState(isRefreshing: true);

    try {
      await ref
          .read(scheduleRepositoryProvider)
          .getWeek(forceRefresh: true, allowStaleOnError: false);
      state = const ScheduleRefreshState();
    } catch (_) {
      final fetchedAt = await ref
          .read(scheduleRepositoryProvider)
          .lastFetchedAt(CacheScopes.scheduleWeek);
      state = ScheduleRefreshState(
        failedAt: ref.read(scheduleNowProvider),
        cachedDataFetchedAt: fetchedAt,
      );
    } finally {
      ref.invalidate(scheduleScreenStateProvider);
    }
  }

  void clearFailure() {
    if (state.failedAt == null) {
      return;
    }

    state = const ScheduleRefreshState();
  }
}

class ScheduleRefreshState {
  const ScheduleRefreshState({
    this.isRefreshing = false,
    this.failedAt,
    this.cachedDataFetchedAt,
  });

  final bool isRefreshing;
  final DateTime? failedAt;
  final DateTime? cachedDataFetchedAt;
}

class ScheduleScreenState {
  const ScheduleScreenState({
    required this.groups,
    required this.fetchedAt,
    required this.isStale,
    required this.hasPersonalEntries,
  });

  final List<ScheduleDayGroup> groups;
  final DateTime? fetchedAt;
  final bool isStale;
  final bool hasPersonalEntries;
}

class ScheduleDayGroup {
  const ScheduleDayGroup({
    required this.publishDay,
    required this.daysUntil,
    required this.items,
  });

  final PublishDay publishDay;
  final int daysUntil;
  final List<ScheduleRowItem> items;
}

class ScheduleRowItem {
  const ScheduleRowItem({
    required this.scheduleItem,
    required this.entry,
    required this.snapshot,
    required this.relevance,
  });

  final ScheduleItem scheduleItem;
  final LibraryEntry entry;
  final LibraryPresentationSnapshot? snapshot;
  final ScheduleRelevance relevance;
}

enum ScheduleRelevance { watching, favorite }

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

List<ScheduleDayGroup> _groupScheduleItems({
  required List<ScheduleItem> schedule,
  required Map<String, LibraryEntry> entries,
  required Map<String, LibraryPresentationSnapshot> snapshots,
  required DateTime now,
}) {
  final items = <ScheduleRowItem>[];

  for (final scheduleItem in schedule) {
    final entry = entries[scheduleItem.releaseId];
    if (entry == null) {
      continue;
    }

    items.add(
      ScheduleRowItem(
        scheduleItem: scheduleItem,
        entry: entry,
        snapshot: snapshots[scheduleItem.releaseId],
        relevance: entry.status == LibraryStatus.watching
            ? ScheduleRelevance.watching
            : ScheduleRelevance.favorite,
      ),
    );
  }

  items.sort((left, right) => _compareScheduleRows(left, right, now: now));

  final groups = <ScheduleDayGroup>[];
  for (final item in items) {
    final publishDay = item.scheduleItem.publishDay;
    final daysUntil = _daysUntil(publishDay, now);
    if (groups.isNotEmpty && groups.last.publishDay == publishDay) {
      groups.last.items.add(item);
      continue;
    }

    groups.add(
      ScheduleDayGroup(
        publishDay: publishDay,
        daysUntil: daysUntil,
        items: [item],
      ),
    );
  }

  return groups;
}

int _compareScheduleRows(
  ScheduleRowItem left,
  ScheduleRowItem right, {
  required DateTime now,
}) {
  final dayComparison = _daysUntil(
    left.scheduleItem.publishDay,
    now,
  ).compareTo(_daysUntil(right.scheduleItem.publishDay, now));
  if (dayComparison != 0) {
    return dayComparison;
  }

  final relevanceComparison = left.relevance.index.compareTo(
    right.relevance.index,
  );
  if (relevanceComparison != 0) {
    return relevanceComparison;
  }

  return _title(left).compareTo(_title(right));
}

String _title(ScheduleRowItem item) {
  final snapshotTitle = item.snapshot?.title.trim();
  if (snapshotTitle != null && snapshotTitle.isNotEmpty) {
    return snapshotTitle;
  }

  return item.scheduleItem.title;
}

bool _isStale(DateTime? fetchedAt, DateTime now) {
  return fetchedAt == null ||
      now.difference(fetchedAt) >= CachePolicy.scheduleWeekTtl;
}

int _daysUntil(PublishDay publishDay, DateTime now) {
  final today = now.weekday;
  final targetDay = publishDay.index + 1;
  return (targetDay - today) % DateTime.daysPerWeek;
}

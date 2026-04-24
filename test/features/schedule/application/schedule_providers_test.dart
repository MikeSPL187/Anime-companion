import 'package:ani_app/core/cache/cache_keys.dart';
import 'package:ani_app/core/error/app_error.dart';
import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/data/providers/schedule_repository_provider.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/library_entry.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/domain/models/schedule_item.dart';
import 'package:ani_app/domain/repositories/library_presentation_snapshot_repository.dart';
import 'package:ani_app/domain/repositories/library_repository.dart';
import 'package:ani_app/domain/repositories/schedule_repository.dart';
import 'package:ani_app/features/schedule/application/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters and groups only personal-relevant schedule items', () async {
    final now = DateTime(2026, 4, 9);
    final container = ProviderContainer(
      overrides: [
        scheduleNowProvider.overrideWithValue(now),
        libraryRepositoryProvider.overrideWithValue(
          FakeLibraryRepository([
            _entry('watching', LibraryStatus.watching, now),
            _entry('favorite', LibraryStatus.planned, now, isFavorite: true),
            _entry('planned', LibraryStatus.planned, now),
            _entry('dropped', LibraryStatus.dropped, now, isFavorite: true),
          ]),
        ),
        libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
          FakeSnapshotRepository({
            'watching': _snapshot('watching', 'Смотрю сейчас'),
            'favorite': _snapshot('favorite', 'Избранное'),
          }),
        ),
        scheduleRepositoryProvider.overrideWithValue(
          FakeScheduleRepository([
            _schedule('planned', PublishDay.thursday),
            _schedule('favorite', PublishDay.friday),
            _schedule('dropped', PublishDay.saturday),
            _schedule('watching', PublishDay.thursday),
          ]),
        ),
      ],
    );
    final subscription = container.listen(
      scheduleScreenStateProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    final state = await container.read(scheduleScreenStateProvider.future);

    expect(state.hasPersonalEntries, isTrue);
    expect(state.groups, hasLength(2));
    expect(state.groups.first.publishDay, PublishDay.thursday);
    expect(state.groups.first.items.single.scheduleItem.releaseId, 'watching');
    expect(state.groups.first.items.single.snapshot?.title, 'Смотрю сейчас');
    expect(state.groups.last.publishDay, PublishDay.friday);
    expect(state.groups.last.items.single.scheduleItem.releaseId, 'favorite');
    expect(
      state.groups.last.items.single.relevance,
      ScheduleRelevance.favorite,
    );
  });

  test(
    'refresh controller forces repository refresh and records cache failure',
    () async {
      final repository = FakeScheduleRepository([
        _schedule('watching', PublishDay.thursday),
      ]);
      final now = DateTime(2026, 4, 9);
      final container = ProviderContainer(
        overrides: [
          scheduleNowProvider.overrideWithValue(now),
          libraryRepositoryProvider.overrideWithValue(
            FakeLibraryRepository([
              _entry('watching', LibraryStatus.watching, now),
            ]),
          ),
          libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
            FakeSnapshotRepository(),
          ),
          scheduleRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(scheduleRefreshControllerProvider.notifier)
          .refresh();

      expect(repository.lastForceRefresh, isTrue);
      expect(repository.lastAllowStaleOnError, isFalse);
      expect(
        container.read(scheduleRefreshControllerProvider).failedAt,
        isNull,
      );

      repository.throwOnForceRefresh = true;

      await container
          .read(scheduleRefreshControllerProvider.notifier)
          .refresh();

      final refreshState = container.read(scheduleRefreshControllerProvider);
      expect(refreshState.failedAt, now);
      expect(refreshState.cachedDataFetchedAt, DateTime(2026, 4, 9, 12));
    },
  );
}

LibraryEntry _entry(
  String animeId,
  LibraryStatus status,
  DateTime at, {
  bool isFavorite = false,
}) {
  return LibraryEntry(
    animeId: animeId,
    status: status,
    isFavorite: isFavorite,
    createdAt: at,
    updatedAt: at,
    lastInteractedAt: at,
  );
}

LibraryPresentationSnapshot _snapshot(String animeId, String title) {
  return LibraryPresentationSnapshot(
    animeId: animeId,
    title: title,
    posterUrl: 'https://example.test/$animeId.webp',
    type: AnimeType.tv,
    episodesTotal: 12,
    snapshotSavedAt: DateTime(2026, 4, 9),
  );
}

ScheduleItem _schedule(String releaseId, PublishDay publishDay) {
  return ScheduleItem(
    releaseId: releaseId,
    title: 'Расписание $releaseId',
    posterUrl: '',
    publishDay: publishDay,
    isOngoing: true,
  );
}

class FakeLibraryRepository implements LibraryRepository {
  FakeLibraryRepository(this._entries);

  final List<LibraryEntry> _entries;

  @override
  Stream<List<LibraryEntry>> watchAll() {
    return Stream.value(_entries);
  }

  @override
  Stream<List<LibraryEntry>> watchByStatus(LibraryStatus status) {
    return Stream.value(
      _entries.where((entry) => entry.status == status).toList(),
    );
  }

  @override
  Future<LibraryEntry?> getByAnimeId(String animeId) async {
    return null;
  }

  @override
  Future<void> setStatus(
    String animeId,
    LibraryStatus status, {
    LibraryPresentationSnapshot? snapshot,
  }) async {}

  @override
  Future<void> toggleFavorite(
    String animeId, {
    LibraryPresentationSnapshot? snapshot,
  }) async {}

  @override
  Future<void> removeFromLibrary(String animeId) async {}

  @override
  Future<void> updateNote(String animeId, String? note) async {}
}

class FakeSnapshotRepository implements LibraryPresentationSnapshotRepository {
  FakeSnapshotRepository([Map<String, LibraryPresentationSnapshot>? snapshots])
    : _snapshots = snapshots ?? {};

  final Map<String, LibraryPresentationSnapshot> _snapshots;

  @override
  Stream<Map<String, LibraryPresentationSnapshot>> watchAll() {
    return Stream.value(_snapshots);
  }

  @override
  Stream<LibraryPresentationSnapshot?> watchByAnimeId(String animeId) {
    return Stream.value(_snapshots[animeId]);
  }

  @override
  Future<LibraryPresentationSnapshot?> getByAnimeId(String animeId) async {
    return _snapshots[animeId];
  }

  @override
  Future<void> saveSnapshot(LibraryPresentationSnapshot snapshot) async {
    _snapshots[snapshot.animeId] = snapshot;
  }

  @override
  Future<void> removeSnapshot(String animeId) async {
    _snapshots.remove(animeId);
  }
}

class FakeScheduleRepository implements ScheduleRepository {
  FakeScheduleRepository(this._week);

  final List<ScheduleItem> _week;
  bool? lastForceRefresh;
  bool? lastAllowStaleOnError;
  bool throwOnForceRefresh = false;

  @override
  Future<List<ScheduleItem>> getToday({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) async {
    return const [];
  }

  @override
  Future<List<ScheduleItem>> getWeek({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) async {
    lastForceRefresh = forceRefresh;
    lastAllowStaleOnError = allowStaleOnError;

    if (forceRefresh && throwOnForceRefresh) {
      throw const NetworkError(message: 'offline');
    }

    return _week;
  }

  @override
  Future<DateTime?> lastFetchedAt(String scope) async {
    return scope == CacheScopes.scheduleWeek ? DateTime(2026, 4, 9, 12) : null;
  }
}

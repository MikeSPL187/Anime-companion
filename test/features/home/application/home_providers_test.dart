import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/data/providers/schedule_repository_provider.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/library_entry.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/domain/models/schedule_item.dart';
import 'package:ani_app/domain/repositories/library_presentation_snapshot_repository.dart';
import 'package:ani_app/domain/repositories/library_repository.dart';
import 'package:ani_app/domain/repositories/schedule_repository.dart';
import 'package:ani_app/features/home/application/home_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('composes continue and what-next items from local library', () async {
    final now = DateTime(2026, 4, 9);
    final container = ProviderContainer(
      overrides: [
        homeNowProvider.overrideWithValue(now),
        libraryRepositoryProvider.overrideWithValue(
          FakeLibraryRepository([
            _entry('watching', LibraryStatus.watching, now),
            _entry(
              'planned-old',
              LibraryStatus.planned,
              now.subtract(const Duration(days: 9)),
            ),
            _entry(
              'planned-new',
              LibraryStatus.planned,
              now.subtract(const Duration(days: 2)),
            ),
            _entry('dropped', LibraryStatus.dropped, now),
          ]),
        ),
        libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
          FakeSnapshotRepository({
            'watching': _snapshot('watching', 'Смотрю сейчас'),
            'planned-old': _snapshot('planned-old', 'Давно в планах'),
          }),
        ),
      ],
    );
    final continueSubscription = container.listen(
      homeContinueItemsProvider,
      (previous, next) {},
    );
    final whatNextSubscription = container.listen(
      homeWhatNextItemsProvider,
      (previous, next) {},
    );
    addTearDown(continueSubscription.close);
    addTearDown(whatNextSubscription.close);
    addTearDown(container.dispose);

    await container.read(homeLibraryEntriesProvider.future);
    await container.read(homeSnapshotsProvider.future);

    final continueItems = container.read(homeContinueItemsProvider).value ?? [];
    final whatNextItems = container.read(homeWhatNextItemsProvider).value ?? [];

    expect(continueItems.map((item) => item.entry.animeId), ['watching']);
    expect(continueItems.single.snapshot?.title, 'Смотрю сейчас');
    expect(whatNextItems.map((item) => item.entry.animeId), ['planned-old']);
    expect(whatNextItems.single.snapshot?.title, 'Давно в планах');
  });

  test('filters schedule preview to personal relevant titles', () async {
    final now = DateTime(2026, 4, 9);
    final container = ProviderContainer(
      overrides: [
        homeNowProvider.overrideWithValue(now),
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
            _schedule('watching', PublishDay.sunday),
          ]),
        ),
      ],
    );
    final previewSubscription = container.listen(
      homeSchedulePreviewProvider,
      (previous, next) {},
    );
    addTearDown(previewSubscription.close);
    addTearDown(container.dispose);

    final preview = await container.read(homeSchedulePreviewProvider.future);

    expect(preview.items.map((item) => item.scheduleItem.releaseId), [
      'watching',
      'favorite',
    ]);
    expect(preview.items.first.priority, HomeSchedulePriority.watching);
    expect(preview.items.last.priority, HomeSchedulePriority.favorite);
    expect(preview.fetchedAt, DateTime(2026, 4, 9, 12));
  });
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
    posterUrl: 'https://example.test/$releaseId.webp',
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
  FakeSnapshotRepository(this._snapshots);

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
    return _week;
  }

  @override
  Future<DateTime?> lastFetchedAt(String scope) async {
    return DateTime(2026, 4, 9, 12);
  }
}

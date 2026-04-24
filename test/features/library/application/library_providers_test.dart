import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/library_entry.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/domain/repositories/library_presentation_snapshot_repository.dart';
import 'package:ani_app/domain/repositories/library_repository.dart';
import 'package:ani_app/features/library/application/library_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters local library entries by selected segment and query', () async {
    final repository = FakeLibraryRepository([
      _entry('1', LibraryStatus.watching),
      _entry('2', LibraryStatus.planned),
      _entry('3', LibraryStatus.planned, note: 'Блич'),
    ]);
    final snapshotRepository = FakeSnapshotRepository({
      '2': _snapshot('2', title: 'Наруто'),
    });
    final container = ProviderContainer(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(repository),
        libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
          snapshotRepository,
        ),
      ],
    );
    final subscription = container.listen(
      libraryFilteredEntriesProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    await container.read(libraryEntriesProvider.future);
    await container.read(librarySnapshotsProvider.future);

    expect(_filteredIds(container), ['1']);

    container
        .read(librarySelectedStatusProvider.notifier)
        .setStatus(LibraryStatus.planned);

    expect(_filteredIds(container), ['2', '3']);

    container.read(libraryFilterProvider.notifier).setFilter('нар');

    expect(_filteredIds(container), ['2']);

    container.read(libraryFilterProvider.notifier).setFilter('3');

    expect(_filteredIds(container), ['3']);
  });
}

List<String> _filteredIds(ProviderContainer container) {
  return (container.read(libraryFilteredEntriesProvider).value ??
          const <LibraryListItem>[])
      .map((item) => item.entry.animeId)
      .toList();
}

LibraryEntry _entry(String animeId, LibraryStatus status, {String? note}) {
  final now = DateTime(2026, 4, 9);
  return LibraryEntry(
    animeId: animeId,
    status: status,
    isFavorite: false,
    createdAt: now,
    updatedAt: now,
    lastInteractedAt: now,
    note: note,
  );
}

LibraryPresentationSnapshot _snapshot(String animeId, {required String title}) {
  return LibraryPresentationSnapshot(
    animeId: animeId,
    title: title,
    snapshotSavedAt: DateTime(2026, 4, 9),
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
    for (final entry in _entries) {
      if (entry.animeId == animeId) {
        return entry;
      }
    }
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

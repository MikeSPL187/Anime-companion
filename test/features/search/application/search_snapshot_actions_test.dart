import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/anime_summary.dart';
import 'package:ani_app/domain/models/library_entry.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/domain/repositories/library_repository.dart';
import 'package:ani_app/features/search/application/search_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog entry status action persists presentation snapshot', () async {
    final repository = RecordingLibraryRepository();
    final container = ProviderContainer(
      overrides: [libraryRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(catalogEntryActionsProvider)
        .setStatus(_summary(), LibraryStatus.planned);

    expect(repository.lastStatusAnimeId, '413');
    expect(repository.lastStatus, LibraryStatus.planned);
    expect(repository.lastStatusSnapshot?.title, 'Наруто');
    expect(
      repository.lastStatusSnapshot?.posterUrl,
      'https://example.test/p.webp',
    );
    expect(repository.lastStatusSnapshot?.episodesTotal, 12);
  });
}

AnimeSummary _summary() {
  return const AnimeSummary(
    id: '413',
    alias: 'naruto',
    title: 'Наруто',
    altTitle: 'Naruto',
    posterUrl: 'https://example.test/p.webp',
    type: AnimeType.tv,
    year: 2007,
    isOngoing: false,
    favoritesCount: 4972,
    episodesTotal: 12,
  );
}

class RecordingLibraryRepository implements LibraryRepository {
  String? lastStatusAnimeId;
  LibraryStatus? lastStatus;
  LibraryPresentationSnapshot? lastStatusSnapshot;

  @override
  Stream<List<LibraryEntry>> watchAll() {
    return const Stream.empty();
  }

  @override
  Stream<List<LibraryEntry>> watchByStatus(LibraryStatus status) {
    return const Stream.empty();
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
  }) async {
    lastStatusAnimeId = animeId;
    lastStatus = status;
    lastStatusSnapshot = snapshot;
  }

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

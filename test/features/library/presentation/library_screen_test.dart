import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/library_entry.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/domain/models/watch_progress.dart';
import 'package:ani_app/domain/repositories/library_presentation_snapshot_repository.dart';
import 'package:ani_app/domain/repositories/library_repository.dart';
import 'package:ani_app/domain/repositories/progress_repository.dart';
import 'package:ani_app/features/library/presentation/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows all-library empty state', (tester) async {
    await tester.pumpWidget(
      _testApp(
        libraryRepository: FakeLibraryRepository(const []),
        snapshotRepository: FakeSnapshotRepository(),
        progressRepository: FakeProgressRepository(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Найди первое аниме и добавь в список'), findsOneWidget);
    expect(find.text('Перейти к поиску'), findsOneWidget);
  });

  testWidgets('renders local watching entry with progress action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        libraryRepository: FakeLibraryRepository([
          _entry(
            '413',
            LibraryStatus.watching,
            isFavorite: true,
            note: 'Пересмотреть арку',
          ),
        ]),
        snapshotRepository: FakeSnapshotRepository({
          '413': _snapshot(
            '413',
            title: 'Наруто: Ураганные хроники',
            altTitle: 'Naruto: Shippuuden',
            episodesTotal: 12,
          ),
        }),
        progressRepository: FakeProgressRepository({
          '413': _progress('413', 7),
        }),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Наруто: Ураганные хроники'), findsOneWidget);
    expect(find.text('Naruto: Shippuuden'), findsOneWidget);
    expect(find.text('Избранное'), findsOneWidget);
    expect(find.text('Прогресс: 7/12'), findsOneWidget);
    expect(find.text('Пересмотреть арку'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('uses honest fallback when snapshot is absent', (tester) async {
    await tester.pumpWidget(
      _testApp(
        libraryRepository: FakeLibraryRepository([
          _entry('999', LibraryStatus.watching),
        ]),
        snapshotRepository: FakeSnapshotRepository(),
        progressRepository: FakeProgressRepository({
          '999': _progress('999', 2),
        }),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Релиз #999'), findsOneWidget);
    expect(find.text('Просмотрено: 2'), findsOneWidget);
  });
}

Widget _testApp({
  required LibraryRepository libraryRepository,
  required LibraryPresentationSnapshotRepository snapshotRepository,
  required ProgressRepository progressRepository,
}) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(libraryRepository),
      libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
        snapshotRepository,
      ),
      progressRepositoryProvider.overrideWithValue(progressRepository),
    ],
    child: const MaterialApp(home: LibraryScreen()),
  );
}

LibraryEntry _entry(
  String animeId,
  LibraryStatus status, {
  bool isFavorite = false,
  String? note,
}) {
  final now = DateTime(2026, 4, 9);
  return LibraryEntry(
    animeId: animeId,
    status: status,
    isFavorite: isFavorite,
    createdAt: now,
    updatedAt: now,
    lastInteractedAt: now,
    note: note,
  );
}

WatchProgress _progress(String animeId, int watchedEpisodes) {
  return WatchProgress(
    animeId: animeId,
    watchedEpisodes: watchedEpisodes,
    lastWatchedEpisode: watchedEpisodes,
    updatedAt: DateTime(2026, 4, 9),
  );
}

LibraryPresentationSnapshot _snapshot(
  String animeId, {
  required String title,
  String? altTitle,
  int? episodesTotal,
}) {
  return LibraryPresentationSnapshot(
    animeId: animeId,
    title: title,
    altTitle: altTitle,
    posterUrl: 'https://example.test/poster.webp',
    type: AnimeType.tv,
    year: 2007,
    episodesTotal: episodesTotal,
    favoritesCount: 4972,
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

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository([Map<String, WatchProgress>? progress])
    : _progress = progress ?? {};

  final Map<String, WatchProgress> _progress;

  @override
  Future<WatchProgress?> getProgress(String animeId) async {
    return _progress[animeId];
  }

  @override
  Stream<WatchProgress?> watchProgress(String animeId) {
    return Stream.value(_progress[animeId]);
  }

  @override
  Future<void> incrementEpisode(String animeId, {int? episodesTotal}) async {
    final current = _progress[animeId];
    final watchedEpisodes = (current?.watchedEpisodes ?? 0) + 1;
    _progress[animeId] = _progressEntry(animeId, watchedEpisodes);
  }

  @override
  Future<void> setEpisode(
    String animeId,
    int episode, {
    int? episodesTotal,
  }) async {
    _progress[animeId] = _progressEntry(animeId, episode);
  }

  @override
  Future<void> clearProgress(String animeId) async {
    _progress.remove(animeId);
  }

  WatchProgress _progressEntry(String animeId, int watchedEpisodes) {
    return WatchProgress(
      animeId: animeId,
      watchedEpisodes: watchedEpisodes,
      lastWatchedEpisode: watchedEpisodes == 0 ? null : watchedEpisodes,
      updatedAt: DateTime(2026, 4, 9),
    );
  }
}

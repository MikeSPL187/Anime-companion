import 'package:ani_app/data/providers/local_repository_providers.dart';
import 'package:ani_app/data/providers/schedule_repository_provider.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/library_entry.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/domain/models/schedule_item.dart';
import 'package:ani_app/domain/models/watch_progress.dart';
import 'package:ani_app/domain/repositories/library_presentation_snapshot_repository.dart';
import 'package:ani_app/domain/repositories/library_repository.dart';
import 'package:ani_app/domain/repositories/progress_repository.dart';
import 'package:ani_app/domain/repositories/schedule_repository.dart';
import 'package:ani_app/features/home/application/home_providers.dart';
import 'package:ani_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders personal Home sections from local context', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 9);

    await tester.pumpWidget(
      _testApp(
        now: now,
        libraryRepository: FakeLibraryRepository([
          _entry('413', LibraryStatus.watching, now, isFavorite: true),
          _entry(
            '777',
            LibraryStatus.planned,
            now.subtract(const Duration(days: 10)),
          ),
        ]),
        snapshotRepository: FakeSnapshotRepository({
          '413': _snapshot('413', 'Наруто: Ураганные хроники'),
          '777': _snapshot('777', 'Стальной алхимик'),
        }),
        progressRepository: FakeProgressRepository({
          '413': _progress('413', 3),
        }),
        scheduleRepository: FakeScheduleRepository([
          _schedule('413', PublishDay.thursday),
        ]),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('В работе: 1 · в планах: 1'), findsOneWidget);
    expect(find.text('Продолжить'), findsOneWidget);
    expect(find.text('Моё расписание'), findsOneWidget);
    expect(find.text('Что дальше'), findsOneWidget);
    expect(find.text('Наруто: Ураганные хроники'), findsWidgets);
    expect(find.text('Прогресс: 3/12'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('Четверг · из «Смотрю»'), findsOneWidget);
    expect(find.text('Стальной алхимик'), findsOneWidget);
  });

  testWidgets(
    'shows honest schedule empty state when nothing personal matches',
    (tester) async {
      final now = DateTime(2026, 4, 9);

      await tester.pumpWidget(
        _testApp(
          now: now,
          libraryRepository: FakeLibraryRepository([
            _entry('413', LibraryStatus.watching, now),
          ]),
          snapshotRepository: FakeSnapshotRepository({
            '413': _snapshot('413', 'Наруто: Ураганные хроники'),
          }),
          progressRepository: FakeProgressRepository({
            '413': _progress('413', 3),
          }),
          scheduleRepository: FakeScheduleRepository([
            _schedule('999', PublishDay.friday),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Моё расписание'), findsOneWidget);
      expect(
        find.text(
          'Добавь онгоинги в «Смотрю» или избранное, чтобы видеть их здесь.',
        ),
        findsOneWidget,
      );
    },
  );
}

Widget _testApp({
  required DateTime now,
  required LibraryRepository libraryRepository,
  required LibraryPresentationSnapshotRepository snapshotRepository,
  required ProgressRepository progressRepository,
  required ScheduleRepository scheduleRepository,
}) {
  return ProviderScope(
    overrides: [
      homeNowProvider.overrideWithValue(now),
      libraryRepositoryProvider.overrideWithValue(libraryRepository),
      libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
        snapshotRepository,
      ),
      progressRepositoryProvider.overrideWithValue(progressRepository),
      scheduleRepositoryProvider.overrideWithValue(scheduleRepository),
    ],
    child: const MaterialApp(home: HomeScreen()),
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

WatchProgress _progress(String animeId, int watchedEpisodes) {
  return WatchProgress(
    animeId: animeId,
    watchedEpisodes: watchedEpisodes,
    lastWatchedEpisode: watchedEpisodes,
    updatedAt: DateTime(2026, 4, 9),
  );
}

LibraryPresentationSnapshot _snapshot(String animeId, String title) {
  return LibraryPresentationSnapshot(
    animeId: animeId,
    title: title,
    type: AnimeType.tv,
    year: 2007,
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

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository(this._progress);

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
  Future<void> incrementEpisode(String animeId, {int? episodesTotal}) async {}

  @override
  Future<void> setEpisode(
    String animeId,
    int episode, {
    int? episodesTotal,
  }) async {}

  @override
  Future<void> clearProgress(String animeId) async {}
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
    return DateTime.now();
  }
}

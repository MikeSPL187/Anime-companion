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
import 'package:ani_app/features/schedule/presentation/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders grouped personal schedule with freshness', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 9);

    await tester.pumpWidget(
      _testApp(
        now: now,
        libraryRepository: FakeLibraryRepository([
          _entry('413', LibraryStatus.watching, now, isFavorite: true),
          _entry('777', LibraryStatus.planned, now, isFavorite: true),
        ]),
        snapshotRepository: FakeSnapshotRepository({
          '413': _snapshot('413', 'Наруто: Ураганные хроники'),
          '777': _snapshot('777', 'Стальной алхимик'),
        }),
        scheduleRepository: FakeScheduleRepository([
          _schedule('413', PublishDay.thursday),
          _schedule('777', PublishDay.friday),
        ]),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Расписание'), findsOneWidget);
    expect(find.text('Личные релизы на ближайшую неделю'), findsOneWidget);
    expect(find.textContaining('Обновлено'), findsOneWidget);
    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Завтра'), findsOneWidget);
    expect(find.text('Наруто: Ураганные хроники'), findsOneWidget);
    expect(find.text('Стальной алхимик'), findsOneWidget);
    expect(find.text('Смотрю'), findsOneWidget);
    expect(find.text('Избранное'), findsWidgets);
  });

  testWidgets('shows personal empty state without generic catalog fallback', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 9);

    await tester.pumpWidget(
      _testApp(
        now: now,
        libraryRepository: FakeLibraryRepository(const []),
        snapshotRepository: FakeSnapshotRepository(),
        scheduleRepository: FakeScheduleRepository([
          _schedule('413', PublishDay.thursday),
        ]),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Добавь аниме в «Смотрю», чтобы видеть своё расписание'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Здесь появляются только тайтлы из вашей библиотеки, без общего каталога.',
      ),
      findsOneWidget,
    );
    expect(find.text('Расписание 413'), findsNothing);
  });
}

Widget _testApp({
  required DateTime now,
  required LibraryRepository libraryRepository,
  required LibraryPresentationSnapshotRepository snapshotRepository,
  required ScheduleRepository scheduleRepository,
}) {
  return ProviderScope(
    overrides: [
      scheduleNowProvider.overrideWithValue(now),
      libraryRepositoryProvider.overrideWithValue(libraryRepository),
      libraryPresentationSnapshotRepositoryProvider.overrideWithValue(
        snapshotRepository,
      ),
      scheduleRepositoryProvider.overrideWithValue(scheduleRepository),
    ],
    child: const MaterialApp(home: ScheduleScreen()),
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
    posterUrl: '',
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
    return DateTime(2026, 4, 9, 11);
  }
}

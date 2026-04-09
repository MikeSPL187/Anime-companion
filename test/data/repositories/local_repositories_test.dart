import 'package:ani_app/core/database/app_database.dart' as db;
import 'package:ani_app/data/repositories/drift_library_repository.dart';
import 'package:ani_app/data/repositories/drift_progress_repository.dart';
import 'package:ani_app/data/repositories/drift_search_history_repository.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late db.AppDatabase database;
  late DriftLibraryRepository libraryRepository;
  late DriftProgressRepository progressRepository;
  late DriftSearchHistoryRepository searchHistoryRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    libraryRepository = DriftLibraryRepository(database);
    progressRepository = DriftProgressRepository(database);
    searchHistoryRepository = DriftSearchHistoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftSearchHistoryRepository', () {
    test('deduplicates saved queries by updating usedAt', () async {
      await searchHistoryRepository.saveQuery(' Naruto ');
      final first = await searchHistoryRepository.getRecent();

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await searchHistoryRepository.saveQuery('Naruto');
      final second = await searchHistoryRepository.getRecent();

      expect(first, hasLength(1));
      expect(second, hasLength(1));
      expect(second.single.query, 'Naruto');
      expect(second.single.usedAt.isAfter(first.single.usedAt), isTrue);
    });

    test('keeps at most 20 entries and removes oldest records', () async {
      await searchHistoryRepository.saveQuery('oldest');
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      for (var index = 0; index < 20; index += 1) {
        await searchHistoryRepository.saveQuery('query-$index');
      }

      final recent = await searchHistoryRepository.getRecent(limit: 25);

      expect(recent, hasLength(20));
      expect(recent.map((entry) => entry.query), isNot(contains('oldest')));
    });

    test('removes individual queries and clears all history', () async {
      await searchHistoryRepository.saveQuery('one');
      await searchHistoryRepository.saveQuery('two');

      await searchHistoryRepository.removeQuery(' one ');
      expect(
        (await searchHistoryRepository.getRecent()).map((entry) => entry.query),
        ['two'],
      );

      await searchHistoryRepository.clearAll();
      expect(await searchHistoryRepository.getRecent(), isEmpty);
    });
  });

  group('DriftLibraryRepository', () {
    test('creates and updates library status timestamps predictably', () async {
      await libraryRepository.setStatus('anime-1', LibraryStatus.planned);
      final created = await libraryRepository.getByAnimeId('anime-1');
      final createdEntry = expectPresent(created);

      expect(createdEntry.status, LibraryStatus.planned);
      expect(createdEntry.isFavorite, isFalse);
      expect(createdEntry.createdAt, createdEntry.updatedAt);
      expect(createdEntry.createdAt, createdEntry.lastInteractedAt);

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await libraryRepository.setStatus('anime-1', LibraryStatus.watching);
      final updated = await libraryRepository.getByAnimeId('anime-1');
      final updatedEntry = expectPresent(updated);

      expect(updatedEntry.status, LibraryStatus.watching);
      expect(updatedEntry.createdAt, createdEntry.createdAt);
      expect(updatedEntry.updatedAt.isAfter(createdEntry.updatedAt), isTrue);
      expect(
        updatedEntry.lastInteractedAt.isAfter(createdEntry.lastInteractedAt),
        isTrue,
      );
    });

    test('toggles favorite and updates lastInteractedAt only', () async {
      await libraryRepository.toggleFavorite('missing');
      expect(await libraryRepository.getByAnimeId('missing'), isNull);

      await libraryRepository.setStatus('anime-1', LibraryStatus.planned);
      final before = await libraryRepository.getByAnimeId('anime-1');
      final beforeEntry = expectPresent(before);

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await libraryRepository.toggleFavorite('anime-1');
      final after = await libraryRepository.getByAnimeId('anime-1');
      final afterEntry = expectPresent(after);

      expect(afterEntry.isFavorite, isTrue);
      expect(afterEntry.status, LibraryStatus.planned);
      expect(afterEntry.createdAt, beforeEntry.createdAt);
      expect(afterEntry.updatedAt, beforeEntry.updatedAt);
      expect(
        afterEntry.lastInteractedAt.isAfter(beforeEntry.lastInteractedAt),
        isTrue,
      );
    });

    test('watches entries by status and removes library records', () async {
      await libraryRepository.setStatus('anime-1', LibraryStatus.watching);
      await libraryRepository.setStatus('anime-2', LibraryStatus.completed);

      final watching = await libraryRepository
          .watchByStatus(LibraryStatus.watching)
          .first;
      expect(watching.map((entry) => entry.animeId), ['anime-1']);

      await libraryRepository.removeFromLibrary('anime-1');

      expect(await libraryRepository.getByAnimeId('anime-1'), isNull);
      expect(await libraryRepository.getByAnimeId('anime-2'), isNotNull);
    });

    test('updates notes without creating missing library records', () async {
      await libraryRepository.updateNote('missing', 'note');
      expect(await libraryRepository.getByAnimeId('missing'), isNull);

      await libraryRepository.setStatus('anime-1', LibraryStatus.planned);
      await libraryRepository.updateNote('anime-1', '  note  ');

      final updated = await libraryRepository.getByAnimeId('anime-1');
      expect(updated?.note, 'note');

      await libraryRepository.updateNote('anime-1', ' ');
      expect((await libraryRepository.getByAnimeId('anime-1'))?.note, isNull);
    });
  });

  group('DriftProgressRepository', () {
    test(
      'increments progress and touches library in one local operation',
      () async {
        await libraryRepository.setStatus('anime-1', LibraryStatus.watching);
        final libraryBefore = await libraryRepository.getByAnimeId('anime-1');
        final libraryEntryBefore = expectPresent(libraryBefore);

        await Future<void>.delayed(const Duration(milliseconds: 1100));
        await progressRepository.incrementEpisode('anime-1', episodesTotal: 2);

        final progress = await progressRepository.getProgress('anime-1');
        final libraryAfter = await libraryRepository.getByAnimeId('anime-1');
        final libraryEntryAfter = expectPresent(libraryAfter);

        expect(progress?.watchedEpisodes, 1);
        expect(progress?.lastWatchedEpisode, 1);
        expect(
          libraryEntryAfter.lastInteractedAt.isAfter(
            libraryEntryBefore.lastInteractedAt,
          ),
          isTrue,
        );
        expect(libraryEntryAfter.updatedAt, libraryEntryBefore.updatedAt);
      },
    );

    test('prevents incrementing beyond a known episode total', () async {
      await libraryRepository.setStatus('anime-1', LibraryStatus.watching);
      await progressRepository.setEpisode('anime-1', 2, episodesTotal: 2);
      final progressBefore = await progressRepository.getProgress('anime-1');
      final libraryBefore = await libraryRepository.getByAnimeId('anime-1');

      await expectLater(
        progressRepository.incrementEpisode('anime-1', episodesTotal: 2),
        throwsStateError,
      );

      final progressAfter = await progressRepository.getProgress('anime-1');
      final libraryAfter = await libraryRepository.getByAnimeId('anime-1');
      expect(progressAfter?.watchedEpisodes, progressBefore?.watchedEpisodes);
      expect(libraryAfter?.lastInteractedAt, libraryBefore?.lastInteractedAt);
    });

    test(
      'allows progress without an artificial upper bound when total unknown',
      () async {
        await libraryRepository.setStatus('anime-1', LibraryStatus.watching);

        await progressRepository.setEpisode('anime-1', 100);
        await progressRepository.incrementEpisode('anime-1');

        final progress = await progressRepository.getProgress('anime-1');
        expect(progress?.watchedEpisodes, 101);
        expect(progress?.lastWatchedEpisode, 101);
      },
    );

    test('rejects incomplete progress for completed library entries', () async {
      await libraryRepository.setStatus('anime-1', LibraryStatus.completed);

      await expectLater(
        progressRepository.setEpisode('anime-1', 11, episodesTotal: 12),
        throwsStateError,
      );

      expect(await progressRepository.getProgress('anime-1'), isNull);

      await progressRepository.setEpisode('anime-1', 12, episodesTotal: 12);
      expect(
        (await progressRepository.getProgress('anime-1'))?.watchedEpisodes,
        12,
      );
    });

    test(
      'rejects negative progress and requires library entry for writes',
      () async {
        await libraryRepository.setStatus('anime-1', LibraryStatus.watching);

        await expectLater(
          progressRepository.setEpisode('anime-1', -1),
          throwsA(isA<RangeError>()),
        );
        await expectLater(
          progressRepository.incrementEpisode('missing'),
          throwsStateError,
        );
      },
    );

    test('clears progress and touches existing library record', () async {
      await libraryRepository.setStatus('anime-1', LibraryStatus.watching);
      await progressRepository.setEpisode('anime-1', 2, episodesTotal: 12);
      final libraryBefore = await libraryRepository.getByAnimeId('anime-1');
      final libraryEntryBefore = expectPresent(libraryBefore);

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await progressRepository.clearProgress('anime-1');

      final libraryAfter = await libraryRepository.getByAnimeId('anime-1');
      final libraryEntryAfter = expectPresent(libraryAfter);
      expect(await progressRepository.getProgress('anime-1'), isNull);
      expect(
        libraryEntryAfter.lastInteractedAt.isAfter(
          libraryEntryBefore.lastInteractedAt,
        ),
        isTrue,
      );
    });
  });
}

T expectPresent<T extends Object>(T? value) {
  if (value == null) {
    fail('Expected a non-null value.');
  }
  return value;
}

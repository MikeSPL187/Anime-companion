import 'dart:convert';

import 'package:ani_app/core/cache/cache_keys.dart';
import 'package:ani_app/core/database/app_database.dart' as db;
import 'package:ani_app/core/error/app_error.dart';
import 'package:ani_app/data/datasources/aniliberty_schedule_remote_data_source.dart';
import 'package:ani_app/data/repositories/aniliberty_schedule_repository.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late db.AppDatabase database;
  late FakeScheduleRemoteDataSource remoteDataSource;
  late AniLibertyScheduleRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    remoteDataSource = FakeScheduleRemoteDataSource();
    repository = AniLibertyScheduleRepository(
      remoteDataSource: remoteDataSource,
      database: database,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('maps and caches AniLiberty week schedule payload', () async {
    remoteDataSource.weekPayload = [_scheduleEntry(413, publishDay: 4)];

    final items = await repository.getWeek();

    expect(items, hasLength(1));
    expect(items.single.releaseId, '413');
    expect(items.single.title, 'Наруто');
    expect(items.single.publishDay, PublishDay.thursday);
    expect(await repository.lastFetchedAt(CacheScopes.scheduleWeek), isNotNull);
  });

  test('returns cached schedule when refresh fails', () async {
    await database
        .into(database.cachedScheduleData)
        .insert(
          db.CachedScheduleDataCompanion.insert(
            scope: CacheScopes.scheduleWeek,
            payload: jsonEncode([_scheduleEntry(413, publishDay: 4)]),
            fetchedAt: DateTime(2026, 4, 1),
          ),
        );
    remoteDataSource.throwOnWeek = true;

    final items = await repository.getWeek();

    expect(items.single.releaseId, '413');
    expect(items.single.publishDay, PublishDay.thursday);
  });

  test('force refresh bypasses fresh cached schedule', () async {
    await database
        .into(database.cachedScheduleData)
        .insert(
          db.CachedScheduleDataCompanion.insert(
            scope: CacheScopes.scheduleWeek,
            payload: jsonEncode([_scheduleEntry(413, publishDay: 4)]),
            fetchedAt: DateTime.now(),
          ),
        );
    remoteDataSource.weekPayload = [_scheduleEntry(777, publishDay: 5)];

    final items = await repository.getWeek(forceRefresh: true);

    expect(items.single.releaseId, '777');
    expect(items.single.publishDay, PublishDay.friday);
  });

  test('ignores corrupted cached schedule and refreshes from remote', () async {
    await database
        .into(database.cachedScheduleData)
        .insert(
          db.CachedScheduleDataCompanion.insert(
            scope: CacheScopes.scheduleWeek,
            payload: '{broken-json',
            fetchedAt: DateTime.now(),
          ),
        );
    remoteDataSource.weekPayload = [_scheduleEntry(777, publishDay: 5)];

    final items = await repository.getWeek();

    expect(items.single.releaseId, '777');
    expect(items.single.publishDay, PublishDay.friday);

    final fetchedAt = await repository.lastFetchedAt(CacheScopes.scheduleWeek);
    expect(fetchedAt, isNotNull);
  });

  test('can surface force refresh failures while cached data exists', () async {
    await database
        .into(database.cachedScheduleData)
        .insert(
          db.CachedScheduleDataCompanion.insert(
            scope: CacheScopes.scheduleWeek,
            payload: jsonEncode([_scheduleEntry(413, publishDay: 4)]),
            fetchedAt: DateTime(2026, 4, 1),
          ),
        );
    remoteDataSource.throwOnWeek = true;

    await expectLater(
      repository.getWeek(forceRefresh: true, allowStaleOnError: false),
      throwsA(isA<ParseError>()),
    );

    final cachedItems = await repository.getWeek();
    expect(cachedItems.single.releaseId, '413');
  });
}

class FakeScheduleRemoteDataSource implements ScheduleRemoteDataSource {
  Object? nowPayload;
  Object? weekPayload;
  bool throwOnWeek = false;

  @override
  Future<Object?> getNowPayload() async {
    return nowPayload ?? {'today': <Object?>[]};
  }

  @override
  Future<Object?> getWeekPayload() async {
    if (throwOnWeek) {
      throw const FormatException('refresh failed');
    }

    return weekPayload ?? <Object?>[];
  }
}

Map<String, Object?> _scheduleEntry(int id, {required int publishDay}) {
  return {
    'release': {
      'id': id,
      'type': {'value': 'TV'},
      'year': 2007,
      'name': {'main': 'Наруто', 'english': 'Naruto'},
      'alias': 'naruto',
      'poster': {
        'optimized': {'preview': '/storage/poster.webp'},
      },
      'is_ongoing': true,
      'publish_day': {'value': publishDay},
      'added_in_users_favorites': 100,
    },
  };
}

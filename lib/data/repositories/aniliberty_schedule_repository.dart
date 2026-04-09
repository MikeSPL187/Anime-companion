import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/cache/cache_keys.dart';
import '../../core/cache/cache_policy.dart';
import '../../core/database/app_database.dart' as db;
import '../../core/error/app_error.dart';
import '../../core/error/dio_error_mapper.dart';
import '../../domain/models/schedule_item.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/aniliberty_schedule_remote_data_source.dart';
import '../dtos/aniliberty_schedule_dto.dart';
import '../mappers/aniliberty_schedule_mapper.dart';

class AniLibertyScheduleRepository implements ScheduleRepository {
  AniLibertyScheduleRepository({
    required ScheduleRemoteDataSource remoteDataSource,
    required db.AppDatabase database,
  }) : _remoteDataSource = remoteDataSource,
       _database = database;

  final ScheduleRemoteDataSource _remoteDataSource;
  final db.AppDatabase _database;

  @override
  Future<List<ScheduleItem>> getToday({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) {
    return _readSchedule(
      scope: CacheScopes.scheduleNow,
      ttl: CachePolicy.scheduleNowTtl,
      forceRefresh: forceRefresh,
      allowStaleOnError: allowStaleOnError,
      fetchPayload: _remoteDataSource.getNowPayload,
      parsePayload: (payload) {
        return AniLibertyScheduleNowDto.fromJson(
          payload,
        ).toTodayScheduleItems();
      },
    );
  }

  @override
  Future<List<ScheduleItem>> getWeek({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) {
    return _readSchedule(
      scope: CacheScopes.scheduleWeek,
      ttl: CachePolicy.scheduleWeekTtl,
      forceRefresh: forceRefresh,
      allowStaleOnError: allowStaleOnError,
      fetchPayload: _remoteDataSource.getWeekPayload,
      parsePayload: (payload) {
        return AniLibertyScheduleWeekDto.fromJson(payload).toScheduleItems();
      },
    );
  }

  @override
  Future<DateTime?> lastFetchedAt(String scope) async {
    final row = await _findCache(scope);
    return row?.fetchedAt;
  }

  Future<List<ScheduleItem>> _readSchedule({
    required String scope,
    required Duration ttl,
    required bool forceRefresh,
    required bool allowStaleOnError,
    required Future<Object?> Function() fetchPayload,
    required List<ScheduleItem> Function(Object? payload) parsePayload,
  }) async {
    final cached = await _readCachedScheduleSafely(scope, parsePayload);
    if (!forceRefresh && cached != null && !_isStale(cached.fetchedAt, ttl)) {
      return cached.items;
    }

    try {
      final payload = await fetchPayload();
      final items = parsePayload(payload);
      await _writeCache(
        scope: scope,
        payload: payload,
        fetchedAt: DateTime.now(),
      );
      return items;
    } on AppError {
      if (allowStaleOnError && cached != null) {
        return cached.items;
      }
      rethrow;
    } on DioException catch (error, stackTrace) {
      if (allowStaleOnError && cached != null) {
        return cached.items;
      }
      Error.throwWithStackTrace(mapDioException(error), stackTrace);
    } on FormatException catch (error, stackTrace) {
      if (allowStaleOnError && cached != null) {
        return cached.items;
      }
      Error.throwWithStackTrace(ParseError(error.message), stackTrace);
    } catch (error, stackTrace) {
      if (allowStaleOnError && cached != null) {
        return cached.items;
      }
      Error.throwWithStackTrace(UnknownError(error), stackTrace);
    }
  }

  Future<_CachedSchedule?> _readCachedScheduleSafely(
    String scope,
    List<ScheduleItem> Function(Object? payload) parsePayload,
  ) async {
    try {
      return await _readCachedSchedule(scope, parsePayload);
    } on FormatException {
      return null;
    }
  }

  Future<_CachedSchedule?> _readCachedSchedule(
    String scope,
    List<ScheduleItem> Function(Object? payload) parsePayload,
  ) async {
    final row = await _findCache(scope);
    if (row == null) {
      return null;
    }

    final decoded = jsonDecode(row.payload);
    return _CachedSchedule(
      items: parsePayload(decoded),
      fetchedAt: row.fetchedAt,
    );
  }

  Future<db.CachedScheduleDataData?> _findCache(String scope) {
    return (_database.select(
      _database.cachedScheduleData,
    )..where((table) => table.scope.equals(scope))).getSingleOrNull();
  }

  Future<void> _writeCache({
    required String scope,
    required Object? payload,
    required DateTime fetchedAt,
  }) {
    return _database
        .into(_database.cachedScheduleData)
        .insertOnConflictUpdate(
          db.CachedScheduleDataCompanion.insert(
            scope: scope,
            payload: jsonEncode(payload),
            fetchedAt: fetchedAt,
          ),
        );
  }

  static bool _isStale(DateTime fetchedAt, Duration ttl) {
    return DateTime.now().difference(fetchedAt) >= ttl;
  }
}

class _CachedSchedule {
  const _CachedSchedule({required this.items, required this.fetchedAt});

  final List<ScheduleItem> items;
  final DateTime fetchedAt;
}

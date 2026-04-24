import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database_provider.dart';
import '../../core/network/dio_provider.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/aniliberty_schedule_remote_data_source.dart';
import '../repositories/aniliberty_schedule_repository.dart';

final scheduleRemoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((
  ref,
) {
  return AniLibertyScheduleRemoteDataSource(ref.watch(dioProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return AniLibertyScheduleRepository(
    remoteDataSource: ref.watch(scheduleRemoteDataSourceProvider),
    database: ref.watch(appDatabaseProvider),
  );
});

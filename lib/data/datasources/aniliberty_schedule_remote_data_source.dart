import 'package:dio/dio.dart';

import 'aniliberty_catalog_remote_data_source.dart';

abstract interface class ScheduleRemoteDataSource {
  Future<Object?> getNowPayload();

  Future<Object?> getWeekPayload();
}

class AniLibertyScheduleRemoteDataSource implements ScheduleRemoteDataSource {
  AniLibertyScheduleRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<Object?> getNowPayload() async {
    final response = await _dio.get<Object?>(
      AniLibertyApiEndpoints.scheduleNow,
    );
    return response.data;
  }

  @override
  Future<Object?> getWeekPayload() async {
    final response = await _dio.get<Object?>(
      AniLibertyApiEndpoints.scheduleWeek,
    );
    return response.data;
  }
}

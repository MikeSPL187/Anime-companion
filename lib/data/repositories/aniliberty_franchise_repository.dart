import 'package:dio/dio.dart';

import '../../core/error/app_error.dart';
import '../../core/error/dio_error_mapper.dart';
import '../../domain/models/franchise_entry.dart';
import '../../domain/repositories/franchise_repository.dart';
import '../datasources/aniliberty_franchise_remote_data_source.dart';
import '../mappers/aniliberty_franchise_mapper.dart';

class AniLibertyFranchiseRepository implements FranchiseRepository {
  AniLibertyFranchiseRepository(this._remoteDataSource);

  final FranchiseRemoteDataSource _remoteDataSource;

  @override
  Future<List<FranchiseEntry>> getByReleaseId(String releaseId) async {
    try {
      final franchises = await _remoteDataSource.getByReleaseId(releaseId);
      return franchises
          .expand((franchise) => franchise.toFranchiseEntries())
          .toList();
    } on AppError {
      rethrow;
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(mapDioException(error), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(ParseError(error.message), stackTrace);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(UnknownError(error), stackTrace);
    }
  }
}

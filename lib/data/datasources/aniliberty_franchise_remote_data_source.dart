import 'package:dio/dio.dart';

import '../dtos/aniliberty_franchise_dto.dart';
import 'aniliberty_catalog_remote_data_source.dart';

abstract interface class FranchiseRemoteDataSource {
  Future<List<AniLibertyFranchiseDto>> getByReleaseId(String releaseId);
}

class AniLibertyFranchiseRemoteDataSource implements FranchiseRemoteDataSource {
  AniLibertyFranchiseRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<AniLibertyFranchiseDto>> getByReleaseId(String releaseId) async {
    final response = await _dio.get<Object?>(
      '${AniLibertyApiEndpoints.franchisesByRelease}/$releaseId',
    );
    return aniLibertyFranchiseDtosFromJsonArray(response.data);
  }
}

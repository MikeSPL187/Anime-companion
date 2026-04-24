import 'package:dio/dio.dart';

import '../dtos/aniliberty_release_dto.dart';

abstract interface class CatalogRemoteDataSource {
  Future<AniLibertyReleasePageDto> searchReleases(String query);

  Future<AniLibertyReleasePageDto> getOngoingReleases({required int page});

  Future<AniLibertyReleasePageDto> getLatestReleases();

  Future<AniLibertyReleasePageDto> getReleasesByGenre({
    required int genreId,
    required int page,
  });

  Future<AniLibertyReleaseDto> getReleaseByIdOrAlias(String idOrAlias);
}

class AniLibertyCatalogRemoteDataSource implements CatalogRemoteDataSource {
  AniLibertyCatalogRemoteDataSource(this._dio);

  static const int pageLimit = 20;

  final Dio _dio;

  @override
  Future<AniLibertyReleasePageDto> searchReleases(String query) async {
    final response = await _dio.get<Object?>(
      AniLibertyApiEndpoints.searchReleases,
      queryParameters: {'query': query},
    );
    final items = aniLibertyReleaseDtosFromJsonArray(response.data);
    return AniLibertyReleasePageDto.fromArray(items, page: 1);
  }

  @override
  Future<AniLibertyReleasePageDto> getOngoingReleases({
    required int page,
  }) async {
    final response = await _dio.get<Object?>(
      AniLibertyApiEndpoints.catalogReleases,
      queryParameters: {
        'page': page,
        'limit': pageLimit,
        'f[publish_statuses]': AniLibertyCatalogFilters.isOngoing,
        'f[sorting]': AniLibertyCatalogFilters.freshFirst,
      },
    );
    return AniLibertyReleasePageDto.fromPaginatedJson(
      response.dataAsJson,
      page,
    );
  }

  @override
  Future<AniLibertyReleasePageDto> getLatestReleases() async {
    final response = await _dio.get<Object?>(
      AniLibertyApiEndpoints.latestReleases,
      queryParameters: {'limit': pageLimit},
    );
    final items = aniLibertyReleaseDtosFromJsonArray(response.data);
    return AniLibertyReleasePageDto.fromArray(items, page: 1);
  }

  @override
  Future<AniLibertyReleasePageDto> getReleasesByGenre({
    required int genreId,
    required int page,
  }) async {
    final response = await _dio.get<Object?>(
      '${AniLibertyApiEndpoints.genreReleases}/$genreId/releases',
      queryParameters: {'page': page, 'limit': pageLimit},
    );
    return AniLibertyReleasePageDto.fromPaginatedJson(
      response.dataAsJson,
      page,
    );
  }

  @override
  Future<AniLibertyReleaseDto> getReleaseByIdOrAlias(String idOrAlias) async {
    final response = await _dio.get<Object?>(
      '${AniLibertyApiEndpoints.releases}/$idOrAlias',
    );
    return AniLibertyReleaseDto.fromJson(response.dataAsJson);
  }
}

abstract final class AniLibertyApiEndpoints {
  static const baseUrl = 'https://anilibria.top/api/v1';
  static const searchReleases = '$baseUrl/app/search/releases';
  static const catalogReleases = '$baseUrl/anime/catalog/releases';
  static const latestReleases = '$baseUrl/anime/releases/latest';
  static const releases = '$baseUrl/anime/releases';
  static const genreReleases = '$baseUrl/anime/genres';
  static const franchisesByRelease = '$baseUrl/anime/franchises/release';
  static const scheduleNow = '$baseUrl/anime/schedule/now';
  static const scheduleWeek = '$baseUrl/anime/schedule/week';
}

abstract final class AniLibertyCatalogFilters {
  static const isOngoing = 'IS_ONGOING';
  static const freshFirst = 'FRESH_AT_DESC';
}

extension on Response<Object?> {
  Map<String, Object?> get dataAsJson {
    final value = data;
    if (value is Map<String, Object?>) {
      return value;
    }

    throw const FormatException('Response data must be an object.');
  }
}

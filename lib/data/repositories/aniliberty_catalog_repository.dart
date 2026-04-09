import 'package:dio/dio.dart';

import '../../core/error/app_error.dart';
import '../../core/error/dio_error_mapper.dart';
import '../../core/pagination/paginated_result.dart';
import '../../domain/models/anime_details.dart';
import '../../domain/models/anime_summary.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/aniliberty_catalog_remote_data_source.dart';
import '../dtos/aniliberty_release_dto.dart';
import '../mappers/aniliberty_release_mapper.dart';

class AniLibertyCatalogRepository implements CatalogRepository {
  AniLibertyCatalogRepository(this._remoteDataSource);

  final CatalogRemoteDataSource _remoteDataSource;

  @override
  Future<PaginatedResult<AnimeSummary>> search(
    String query, {
    int page = 1,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || page > 1) {
      return PaginatedResult(items: const [], page: page, hasNextPage: false);
    }

    return _runCatalogRead(
      () => _remoteDataSource.searchReleases(normalizedQuery),
    );
  }

  @override
  Future<PaginatedResult<AnimeSummary>> getOngoing({int page = 1}) {
    return _runCatalogRead(
      () => _remoteDataSource.getOngoingReleases(page: page),
    );
  }

  @override
  Future<PaginatedResult<AnimeSummary>> getLatest({int page = 1}) async {
    if (page > 1) {
      return PaginatedResult(items: const [], page: page, hasNextPage: false);
    }

    return _runCatalogRead(_remoteDataSource.getLatestReleases);
  }

  @override
  Future<PaginatedResult<AnimeSummary>> getByGenre(
    String genre, {
    int page = 1,
  }) {
    final genreId = int.tryParse(genre);
    if (genreId == null) {
      return Future<PaginatedResult<AnimeSummary>>.error(
        const ParseError('Genre lookup requires a numeric genre id.'),
      );
    }

    return _runCatalogRead(
      () => _remoteDataSource.getReleasesByGenre(genreId: genreId, page: page),
    );
  }

  @override
  Future<AnimeDetails> getDetails(String animeId) {
    return getByIdOrAlias(animeId);
  }

  @override
  Future<AnimeDetails> getByIdOrAlias(String idOrAlias) {
    return _runDetailsRead(
      () => _remoteDataSource.getReleaseByIdOrAlias(idOrAlias),
    );
  }

  Future<PaginatedResult<AnimeSummary>> _runCatalogRead(
    Future<AniLibertyReleasePageDto> Function() read,
  ) async {
    try {
      final page = await read();
      return PaginatedResult(
        items: page.items.map((item) => item.toAnimeSummary()).toList(),
        page: page.page,
        hasNextPage: page.hasNextPage,
      );
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

  Future<AnimeDetails> _runDetailsRead(
    Future<AniLibertyReleaseDto> Function() read,
  ) async {
    try {
      final release = await read();
      return release.toAnimeDetails();
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

import '../../core/pagination/paginated_result.dart';
import '../models/anime_details.dart';
import '../models/anime_summary.dart';

abstract interface class CatalogRepository {
  Future<PaginatedResult<AnimeSummary>> search(String query, {int page = 1});

  Future<PaginatedResult<AnimeSummary>> getOngoing({int page = 1});

  Future<PaginatedResult<AnimeSummary>> getLatest({int page = 1});

  Future<PaginatedResult<AnimeSummary>> getByGenre(
    String genre, {
    int page = 1,
  });

  Future<AnimeDetails> getDetails(String animeId);

  Future<AnimeDetails> getByIdOrAlias(String idOrAlias);
}

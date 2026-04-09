import 'package:ani_app/data/datasources/aniliberty_catalog_remote_data_source.dart';
import 'package:ani_app/data/dtos/aniliberty_release_dto.dart';
import 'package:ani_app/data/repositories/aniliberty_catalog_repository.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeCatalogRemoteDataSource remoteDataSource;
  late AniLibertyCatalogRepository repository;

  setUp(() {
    remoteDataSource = FakeCatalogRemoteDataSource();
    repository = AniLibertyCatalogRepository(remoteDataSource);
  });

  test('search trims query and maps remote releases', () async {
    final result = await repository.search('  Наруто  ');

    expect(remoteDataSource.lastSearchQuery, 'Наруто');
    expect(result.items.single.title, 'Наруто');
    expect(result.items.single.type, AnimeType.tv);
    expect(result.page, 1);
    expect(result.hasNextPage, isFalse);
  });

  test(
    'search returns an empty page without remote call for blank query',
    () async {
      final result = await repository.search('   ');

      expect(result.items, isEmpty);
      expect(remoteDataSource.searchCallCount, 0);
    },
  );

  test('latest endpoint is used only for the first page', () async {
    final firstPage = await repository.getLatest();
    final secondPage = await repository.getLatest(page: 2);

    expect(firstPage.items, hasLength(1));
    expect(secondPage.items, isEmpty);
    expect(remoteDataSource.latestCallCount, 1);
  });

  test('ongoing and numeric genre lookups keep paginated metadata', () async {
    final ongoing = await repository.getOngoing(page: 3);
    final byGenre = await repository.getByGenre('15', page: 2);

    expect(remoteDataSource.lastOngoingPage, 3);
    expect(remoteDataSource.lastGenreId, 15);
    expect(remoteDataSource.lastGenrePage, 2);
    expect(ongoing.hasNextPage, isTrue);
    expect(byGenre.hasNextPage, isTrue);
  });

  test('details lookup uses id or alias endpoint and maps details', () async {
    final details = await repository.getByIdOrAlias('naruto');

    expect(remoteDataSource.lastDetailsIdOrAlias, 'naruto');
    expect(details.summary.id, '413');
    expect(details.summary.title, 'Наруто');
    expect(details.genres, ['Сёнен']);
    expect(details.episodes.single.number, 1);
    expect(details.membersCount, 1);
  });
}

class FakeCatalogRemoteDataSource implements CatalogRemoteDataSource {
  String? lastSearchQuery;
  int searchCallCount = 0;
  int latestCallCount = 0;
  int? lastOngoingPage;
  int? lastGenreId;
  int? lastGenrePage;
  String? lastDetailsIdOrAlias;

  @override
  Future<AniLibertyReleasePageDto> searchReleases(String query) async {
    searchCallCount += 1;
    lastSearchQuery = query;
    return AniLibertyReleasePageDto.fromArray([_release()], page: 1);
  }

  @override
  Future<AniLibertyReleasePageDto> getLatestReleases() async {
    latestCallCount += 1;
    return AniLibertyReleasePageDto.fromArray([_release()], page: 1);
  }

  @override
  Future<AniLibertyReleasePageDto> getOngoingReleases({
    required int page,
  }) async {
    lastOngoingPage = page;
    return AniLibertyReleasePageDto(
      items: [_release()],
      page: page,
      hasNextPage: true,
    );
  }

  @override
  Future<AniLibertyReleasePageDto> getReleasesByGenre({
    required int genreId,
    required int page,
  }) async {
    lastGenreId = genreId;
    lastGenrePage = page;
    return AniLibertyReleasePageDto(
      items: [_release()],
      page: page,
      hasNextPage: true,
    );
  }

  @override
  Future<AniLibertyReleaseDto> getReleaseByIdOrAlias(String idOrAlias) async {
    lastDetailsIdOrAlias = idOrAlias;
    return _release();
  }

  AniLibertyReleaseDto _release() {
    return const AniLibertyReleaseDto(
      id: 413,
      alias: 'naruto',
      name: AniLibertyReleaseNameDto(main: 'Наруто'),
      poster: AniLibertyImageDto(preview: '/poster.webp'),
      type: 'TV',
      isOngoing: false,
      favoritesCount: 100,
      genres: const ['Сёнен'],
      episodes: const [AniLibertyReleaseEpisodeDto(number: 1)],
      membersCount: 1,
    );
  }
}

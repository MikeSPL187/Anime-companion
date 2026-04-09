import 'package:ani_app/data/datasources/aniliberty_franchise_remote_data_source.dart';
import 'package:ani_app/data/dtos/aniliberty_franchise_dto.dart';
import 'package:ani_app/data/dtos/aniliberty_release_dto.dart';
import 'package:ani_app/data/mappers/aniliberty_franchise_mapper.dart';
import 'package:ani_app/data/repositories/aniliberty_franchise_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps franchise releases using contract ordering', () {
    final dto = AniLibertyFranchiseDto(
      id: '7',
      releases: [
        _franchiseRelease(releaseId: 30, year: 2001),
        _franchiseRelease(releaseId: 20, sortOrder: 2, year: 2020),
        _franchiseRelease(releaseId: 10, sortOrder: 1, year: 2021),
        _franchiseRelease(releaseId: 40, year: 1999),
        _franchiseRelease(releaseId: 35, year: 2001),
      ],
    );

    final entries = dto.toFranchiseEntries();

    expect(entries.map((entry) => entry.releaseId), [
      '10',
      '20',
      '40',
      '30',
      '35',
    ]);
  });

  test(
    'repository returns ordered franchise entries from remote data',
    () async {
      final repository = AniLibertyFranchiseRepository(
        FakeFranchiseRemoteDataSource(),
      );

      final entries = await repository.getByReleaseId('413');

      expect(entries.map((entry) => entry.releaseId), ['2', '1']);
      expect(entries.map((entry) => entry.summary.title), ['Второй', 'Первый']);
    },
  );
}

class FakeFranchiseRemoteDataSource implements FranchiseRemoteDataSource {
  @override
  Future<List<AniLibertyFranchiseDto>> getByReleaseId(String releaseId) async {
    return [
      AniLibertyFranchiseDto(
        id: 'franchise',
        releases: [
          _franchiseRelease(releaseId: 1, sortOrder: 2, title: 'Первый'),
          _franchiseRelease(releaseId: 2, sortOrder: 1, title: 'Второй'),
        ],
      ),
    ];
  }
}

AniLibertyFranchiseReleaseDto _franchiseRelease({
  required int releaseId,
  int? sortOrder,
  int? year,
  String? title,
}) {
  return AniLibertyFranchiseReleaseDto(
    franchiseId: 'franchise',
    releaseId: releaseId,
    sortOrder: sortOrder,
    release: AniLibertyReleaseDto(
      id: releaseId,
      alias: 'release-$releaseId',
      name: AniLibertyReleaseNameDto(main: title ?? 'Релиз $releaseId'),
      poster: const AniLibertyImageDto(preview: '/poster.webp'),
      type: 'TV',
      year: year,
      isOngoing: false,
      favoritesCount: 0,
    ),
  );
}

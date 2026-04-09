import 'package:ani_app/data/dtos/aniliberty_release_dto.dart';
import 'package:ani_app/data/mappers/aniliberty_release_mapper.dart';
import 'package:ani_app/domain/enums/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'maps AniLiberty release payload to AnimeSummary without inferred fields',
    () {
      final dto = AniLibertyReleaseDto.fromJson({
        'id': 413,
        'type': {'value': 'TV', 'description': 'ТВ'},
        'year': 2007,
        'name': {
          'main': 'Наруто Ураганные хроники',
          'english': 'Naruto: Shippuuden',
          'alternative': null,
        },
        'alias': 'naruto-shippuuden-naruto-uragannye-khroniki',
        'season': {'value': 'spring', 'description': 'Весна'},
        'poster': {
          'preview': '/storage/poster.jpg',
          'optimized': {'preview': '/storage/poster.webp'},
        },
        'updated_at': '2024-08-02T19:50:36+00:00',
        'is_ongoing': false,
        'age_rating': {'value': 'R16_PLUS', 'label': '16+'},
        'publish_day': {'value': 1, 'description': 'Понедельник'},
        'episodes_total': 450,
        'latest_episode': {'ordinal': 500},
        'added_in_users_favorites': 4972,
      });

      final summary = dto.toAnimeSummary();

      expect(summary.id, '413');
      expect(summary.alias, 'naruto-shippuuden-naruto-uragannye-khroniki');
      expect(summary.title, 'Наруто Ураганные хроники');
      expect(summary.altTitle, 'Naruto: Shippuuden');
      expect(summary.posterUrl, 'https://anilibria.top/storage/poster.webp');
      expect(summary.type, AnimeType.tv);
      expect(summary.season, AnimeSeason.spring);
      expect(summary.publishDay, PublishDay.monday);
      expect(summary.ageRating, AgeRating.r);
      expect(summary.favoritesCount, 4972);
      expect(summary.episodesTotal, 450);
      expect(summary.episodesAired, isNull);
      expect(summary.updatedAt, DateTime.parse('2024-08-02T19:50:36+00:00'));
    },
  );

  test(
    'keeps optional fields unknown when AniLiberty does not provide them',
    () {
      final dto = AniLibertyReleaseDto.fromJson({
        'id': 101,
        'name': {'main': 'Название'},
        'poster': <String, Object?>{},
        'is_ongoing': true,
      });

      final summary = dto.toAnimeSummary();

      expect(summary.alias, '101');
      expect(summary.altTitle, isNull);
      expect(summary.posterUrl, '');
      expect(summary.type, AnimeType.unknown);
      expect(summary.year, isNull);
      expect(summary.season, isNull);
      expect(summary.favoritesCount, 0);
      expect(summary.episodesTotal, isNull);
      expect(summary.episodesAired, isNull);
    },
  );

  test('maps AniLiberty details payload to AnimeDetails', () {
    final dto = AniLibertyReleaseDto.fromJson({
      'id': 501,
      'type': {'value': 'TV', 'description': 'ТВ'},
      'year': 2024,
      'name': {'main': 'Детальное название', 'english': 'Details Title'},
      'alias': 'details-title',
      'poster': {
        'optimized': {'preview': '/storage/details.webp'},
      },
      'is_ongoing': true,
      'description': 'Описание тайтла',
      'genres': [
        {'id': 1, 'name': 'Приключения'},
        {'id': 2, 'name': 'Фэнтези'},
      ],
      'episodes': [
        {'id': 'ep-1', 'name': 'Первая серия', 'sort_order': 1},
        {'id': 'ep-2', 'name_english': 'Second episode', 'ordinal': 2},
      ],
      'members': [
        {'id': 10},
        {'id': 11},
      ],
      'is_blocked_by_geo': true,
      'is_blocked_by_copyrights': true,
      'average_duration_of_episode': 24,
      'added_in_users_favorites': 15,
    });

    final details = dto.toAnimeDetails();

    expect(details.summary.id, '501');
    expect(details.summary.title, 'Детальное название');
    expect(details.description, 'Описание тайтла');
    expect(details.genres, ['Приключения', 'Фэнтези']);
    expect(details.episodes.map((episode) => episode.number), [1, 2]);
    expect(details.episodes.map((episode) => episode.title), [
      'Первая серия',
      'Second episode',
    ]);
    expect(details.membersCount, 2);
    expect(details.blockedByGeo, isTrue);
    expect(details.blockedByCopyright, isTrue);
    expect(details.averageEpisodeDurationSec, 1440);
  });
}

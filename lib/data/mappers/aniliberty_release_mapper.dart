import '../../domain/enums/enums.dart';
import '../../domain/models/anime_details.dart';
import '../../domain/models/anime_episode.dart';
import '../../domain/models/anime_summary.dart';
import '../dtos/aniliberty_release_dto.dart';

abstract final class AniLibertyAssets {
  static const baseUrl = 'https://anilibria.top';
}

extension AniLibertyReleaseMapper on AniLibertyReleaseDto {
  AnimeSummary toAnimeSummary() {
    return AnimeSummary(
      id: id.toString(),
      alias: alias,
      title: name.main,
      altTitle: _differentOrNull(name.english, name.main),
      posterUrl: _absoluteAssetUrl(poster.preview ?? poster.src ?? ''),
      type: _mapAnimeType(type),
      year: year,
      season: _mapAnimeSeason(season),
      isOngoing: isOngoing,
      publishDay: _mapPublishDay(publishDay),
      ageRating: _mapAgeRating(ageRating),
      favoritesCount: favoritesCount,
      episodesTotal: episodesTotal,
      episodesAired: episodesAired,
      updatedAt: updatedAt,
    );
  }

  AnimeDetails toAnimeDetails() {
    final averageDurationMinutes = averageEpisodeDurationMinutes;

    return AnimeDetails(
      summary: toAnimeSummary(),
      description: description,
      genres: genres,
      episodes: episodes
          .map(
            (episode) =>
                AnimeEpisode(number: episode.number, title: episode.title),
          )
          .toList(),
      membersCount: membersCount,
      blockedByGeo: blockedByGeo,
      blockedByCopyright: blockedByCopyright,
      averageEpisodeDurationSec: averageDurationMinutes == null
          ? null
          : averageDurationMinutes * 60,
    );
  }
}

String? _differentOrNull(String? value, String primary) {
  if (value == null || value == primary) {
    return null;
  }

  return value;
}

String _absoluteAssetUrl(String value) {
  if (value.isEmpty ||
      value.startsWith('http://') ||
      value.startsWith('https://')) {
    return value;
  }

  return '${AniLibertyAssets.baseUrl}$value';
}

AnimeType _mapAnimeType(String? value) {
  return switch (value) {
    'TV' => AnimeType.tv,
    'MOVIE' => AnimeType.movie,
    'OVA' || 'OAD' => AnimeType.ova,
    'ONA' || 'WEB' => AnimeType.ona,
    'SPECIAL' => AnimeType.special,
    _ => AnimeType.unknown,
  };
}

AnimeSeason? _mapAnimeSeason(String? value) {
  return switch (value) {
    'winter' => AnimeSeason.winter,
    'spring' => AnimeSeason.spring,
    'summer' => AnimeSeason.summer,
    'autumn' => AnimeSeason.fall,
    _ => null,
  };
}

PublishDay? _mapPublishDay(int? value) {
  return switch (value) {
    1 => PublishDay.monday,
    2 => PublishDay.tuesday,
    3 => PublishDay.wednesday,
    4 => PublishDay.thursday,
    5 => PublishDay.friday,
    6 => PublishDay.saturday,
    7 => PublishDay.sunday,
    _ => null,
  };
}

AgeRating? _mapAgeRating(String? value) {
  return switch (value) {
    'R0_PLUS' => AgeRating.g,
    'R6_PLUS' => AgeRating.pg,
    'R12_PLUS' => AgeRating.pg13,
    'R16_PLUS' => AgeRating.r,
    'R18_PLUS' => AgeRating.rPlus,
    _ => null,
  };
}

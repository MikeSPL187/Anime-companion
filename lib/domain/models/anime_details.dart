import 'anime_episode.dart';
import 'anime_summary.dart';

class AnimeDetails {
  const AnimeDetails({
    required this.summary,
    required this.genres,
    required this.episodes,
    required this.blockedByGeo,
    required this.blockedByCopyright,
    this.description,
    this.membersCount,
    this.averageEpisodeDurationSec,
  });

  final AnimeSummary summary;
  final String? description;
  final List<String> genres;
  final List<AnimeEpisode> episodes;
  final int? membersCount;
  final bool blockedByGeo;
  final bool blockedByCopyright;
  final int? averageEpisodeDurationSec;
}

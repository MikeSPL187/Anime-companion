abstract final class CacheScopes {
  static const scheduleNow = 'now';
  static const scheduleWeek = 'week';
}

abstract final class CacheKeys {
  static const scheduleNow = 'schedule/now';
  static const scheduleWeek = 'schedule/week';

  static String releaseDetails(String animeId) => 'release/details/$animeId';

  static String franchise(String releaseId) => 'franchise/$releaseId';

  static String summaryList({required String scope, required int page}) {
    return 'summary/$scope/page/$page';
  }
}

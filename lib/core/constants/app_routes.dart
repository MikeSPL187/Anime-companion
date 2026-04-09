abstract final class AppRoutes {
  static const home = '/home';
  static const search = '/search';
  static const library = '/library';
  static const schedule = '/schedule';
  static const settings = '/settings';
  static const animeDetailsPattern = '/anime/:id';

  static String animeDetails(String animeId) => '/anime/$animeId';
}

abstract final class AppRouteParams {
  static const animeId = 'id';
}

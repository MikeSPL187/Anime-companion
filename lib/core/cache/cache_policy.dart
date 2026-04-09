abstract final class CachePolicy {
  static const scheduleNowTtl = Duration(minutes: 15);
  static const scheduleWeekTtl = Duration(hours: 6);
  static const releaseDetailsTtl = Duration(hours: 24);
  static const summaryListsTtl = Duration(hours: 4);
  static const franchiseDataTtl = Duration(hours: 12);
}

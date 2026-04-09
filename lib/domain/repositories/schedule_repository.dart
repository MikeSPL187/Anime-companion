import '../models/schedule_item.dart';

abstract interface class ScheduleRepository {
  Future<List<ScheduleItem>> getToday();

  Future<List<ScheduleItem>> getWeek();

  Future<DateTime?> lastFetchedAt(String scope);
}

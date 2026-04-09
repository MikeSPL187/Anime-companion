import '../models/schedule_item.dart';

abstract interface class ScheduleRepository {
  Future<List<ScheduleItem>> getToday({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  });

  Future<List<ScheduleItem>> getWeek({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  });

  Future<DateTime?> lastFetchedAt(String scope);
}

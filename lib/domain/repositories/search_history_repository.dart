import '../models/search_history_entry.dart';

abstract interface class SearchHistoryRepository {
  Future<List<SearchHistoryEntry>> getRecent({int limit = 10});

  Future<void> saveQuery(String query);

  Future<void> removeQuery(String query);

  Future<void> clearAll();
}

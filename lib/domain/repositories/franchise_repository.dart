import '../models/franchise_entry.dart';

abstract interface class FranchiseRepository {
  Future<List<FranchiseEntry>> getByReleaseId(String releaseId);
}

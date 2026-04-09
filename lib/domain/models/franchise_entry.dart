import 'anime_summary.dart';

class FranchiseEntry {
  const FranchiseEntry({
    required this.franchiseId,
    required this.releaseId,
    required this.summary,
    this.sortOrder,
  });

  final String franchiseId;
  final String releaseId;
  final int? sortOrder;
  final AnimeSummary summary;
}

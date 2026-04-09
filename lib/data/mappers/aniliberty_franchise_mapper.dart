import '../../domain/models/franchise_entry.dart';
import '../dtos/aniliberty_franchise_dto.dart';
import 'aniliberty_release_mapper.dart';

extension AniLibertyFranchiseMapper on AniLibertyFranchiseDto {
  List<FranchiseEntry> toFranchiseEntries() {
    final entries = releases
        .map((release) => release.toFranchiseEntry())
        .toList();
    entries.sort(_compareFranchiseEntries);
    return entries;
  }
}

extension AniLibertyFranchiseReleaseMapper on AniLibertyFranchiseReleaseDto {
  FranchiseEntry toFranchiseEntry() {
    return FranchiseEntry(
      franchiseId: franchiseId,
      releaseId: releaseId.toString(),
      sortOrder: sortOrder,
      summary: release.toAnimeSummary(),
    );
  }
}

int _compareFranchiseEntries(FranchiseEntry left, FranchiseEntry right) {
  final sortOrderComparison = _compareNullableInt(
    left.sortOrder,
    right.sortOrder,
  );
  if (sortOrderComparison != 0) {
    return sortOrderComparison;
  }

  final yearComparison = _compareNullableInt(
    left.summary.year,
    right.summary.year,
  );
  if (yearComparison != 0) {
    return yearComparison;
  }

  return _compareReleaseId(left.releaseId, right.releaseId);
}

int _compareNullableInt(int? left, int? right) {
  if (left == null && right == null) {
    return 0;
  }
  if (left == null) {
    return 1;
  }
  if (right == null) {
    return -1;
  }

  return left.compareTo(right);
}

int _compareReleaseId(String left, String right) {
  final leftNumber = int.tryParse(left);
  final rightNumber = int.tryParse(right);
  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }

  return left.compareTo(right);
}

import 'aniliberty_release_dto.dart';

class AniLibertyFranchiseDto {
  const AniLibertyFranchiseDto({required this.id, required this.releases});

  final String id;
  final List<AniLibertyFranchiseReleaseDto> releases;

  factory AniLibertyFranchiseDto.fromJson(Map<String, Object?> json) {
    final id = _readString(json['id']);
    if (id == null) {
      throw const FormatException('Franchise id is missing.');
    }

    return AniLibertyFranchiseDto(
      id: id,
      releases: _readList(json['franchise_releases'], 'franchise_releases')
          .map(
            (item) => AniLibertyFranchiseReleaseDto.fromJson(
              _readObject(item, 'franchise_release'),
            ),
          )
          .toList(),
    );
  }
}

class AniLibertyFranchiseReleaseDto {
  const AniLibertyFranchiseReleaseDto({
    required this.franchiseId,
    required this.releaseId,
    required this.release,
    this.sortOrder,
  });

  final String franchiseId;
  final int releaseId;
  final int? sortOrder;
  final AniLibertyReleaseDto release;

  factory AniLibertyFranchiseReleaseDto.fromJson(Map<String, Object?> json) {
    return AniLibertyFranchiseReleaseDto(
      franchiseId: _readString(json['franchise_id']) ?? '',
      releaseId: _readInt(json['release_id'], 'release_id'),
      sortOrder: _readIntOrNull(json['sort_order']),
      release: AniLibertyReleaseDto.fromJson(
        _readObject(json['release'], 'release'),
      ),
    );
  }
}

List<AniLibertyFranchiseDto> aniLibertyFranchiseDtosFromJsonArray(
  Object? data,
) {
  return _readList(data, 'franchises')
      .map(
        (item) =>
            AniLibertyFranchiseDto.fromJson(_readObject(item, 'franchise')),
      )
      .toList();
}

Map<String, Object?> _readObject(Object? value, String fieldName) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw FormatException('$fieldName must be an object.');
}

List<Object?> _readList(Object? value, String fieldName) {
  if (value is List<Object?>) {
    return value;
  }

  throw FormatException('$fieldName must be a list.');
}

String? _readString(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

int _readInt(Object? value, String fieldName) {
  final parsed = _readIntOrNull(value);
  if (parsed == null) {
    throw FormatException('$fieldName must be a number.');
  }

  return parsed;
}

int? _readIntOrNull(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return null;
}

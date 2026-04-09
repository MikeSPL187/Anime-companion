import 'aniliberty_release_dto.dart';

class AniLibertyScheduleNowDto {
  const AniLibertyScheduleNowDto({
    required this.today,
    required this.tomorrow,
    required this.yesterday,
  });

  final List<AniLibertyScheduleEntryDto> today;
  final List<AniLibertyScheduleEntryDto> tomorrow;
  final List<AniLibertyScheduleEntryDto> yesterday;

  factory AniLibertyScheduleNowDto.fromJson(Object? data) {
    final json = _readObject(data, 'schedule');

    return AniLibertyScheduleNowDto(
      today: _readScheduleList(json['today']),
      tomorrow: _readScheduleList(json['tomorrow']),
      yesterday: _readScheduleList(json['yesterday']),
    );
  }
}

class AniLibertyScheduleWeekDto {
  const AniLibertyScheduleWeekDto({required this.items});

  final List<AniLibertyScheduleEntryDto> items;

  factory AniLibertyScheduleWeekDto.fromJson(Object? data) {
    if (data is List<Object?>) {
      return AniLibertyScheduleWeekDto(items: _readScheduleList(data));
    }

    final json = _readObject(data, 'schedule');
    return AniLibertyScheduleWeekDto(items: _readScheduleList(json['data']));
  }
}

class AniLibertyScheduleEntryDto {
  const AniLibertyScheduleEntryDto({required this.release});

  final AniLibertyReleaseDto release;

  factory AniLibertyScheduleEntryDto.fromJson(Map<String, Object?> json) {
    return AniLibertyScheduleEntryDto(
      release: AniLibertyReleaseDto.fromJson(
        _readObject(json['release'], 'release'),
      ),
    );
  }
}

List<AniLibertyScheduleEntryDto> _readScheduleList(Object? value) {
  if (value == null) {
    return const [];
  }

  return _readList(value, 'schedule entries')
      .map(
        (item) => AniLibertyScheduleEntryDto.fromJson(
          _readObject(item, 'schedule entry'),
        ),
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

class AniLibertyReleaseDto {
  const AniLibertyReleaseDto({
    required this.id,
    required this.alias,
    required this.name,
    required this.poster,
    required this.type,
    required this.isOngoing,
    required this.favoritesCount,
    this.year,
    this.season,
    this.publishDay,
    this.ageRating,
    this.episodesTotal,
    this.episodesAired,
    this.updatedAt,
    this.description,
    this.genres = const [],
    this.episodes = const [],
    this.membersCount,
    this.blockedByGeo = false,
    this.blockedByCopyright = false,
    this.averageEpisodeDurationMinutes,
  });

  final int id;
  final String alias;
  final AniLibertyReleaseNameDto name;
  final AniLibertyImageDto poster;
  final String? type;
  final int? year;
  final String? season;
  final bool isOngoing;
  final int? publishDay;
  final String? ageRating;
  final int favoritesCount;
  final int? episodesTotal;
  final int? episodesAired;
  final DateTime? updatedAt;
  final String? description;
  final List<String> genres;
  final List<AniLibertyReleaseEpisodeDto> episodes;
  final int? membersCount;
  final bool blockedByGeo;
  final bool blockedByCopyright;
  final int? averageEpisodeDurationMinutes;

  factory AniLibertyReleaseDto.fromJson(Map<String, Object?> json) {
    final id = _readInt(json['id'], 'id');
    final nameJson = _readObject(json['name'], 'name');
    final posterJson = _readObject(json['poster'], 'poster');

    return AniLibertyReleaseDto(
      id: id,
      alias: _readString(json['alias']) ?? id.toString(),
      name: AniLibertyReleaseNameDto.fromJson(nameJson),
      poster: AniLibertyImageDto.fromJson(posterJson),
      type: _readValueObjectString(json['type']),
      year: _readIntOrNull(json['year']),
      season: _readValueObjectString(json['season']),
      isOngoing: _readBool(json['is_ongoing']) ?? false,
      publishDay: _readValueObjectInt(json['publish_day']),
      ageRating: _readValueObjectString(json['age_rating']),
      favoritesCount: _readIntOrNull(json['added_in_users_favorites']) ?? 0,
      episodesTotal: _readIntOrNull(json['episodes_total']),
      episodesAired: _readIntOrNull(json['episodes_aired']),
      updatedAt: _readDateTime(json['updated_at']),
      description: _readString(json['description']),
      genres:
          _readListOrNull(json['genres'])
              ?.map((item) => _readString(_readObject(item, 'genre')['name']))
              .nonNulls
              .toList() ??
          const [],
      episodes:
          _readListOrNull(json['episodes'])
              ?.map(
                (item) => AniLibertyReleaseEpisodeDto.fromJson(
                  _readObject(item, 'episode'),
                ),
              )
              .toList() ??
          const [],
      membersCount: _readListOrNull(json['members'])?.length,
      blockedByGeo: _readBool(json['is_blocked_by_geo']) ?? false,
      blockedByCopyright: _readBool(json['is_blocked_by_copyrights']) ?? false,
      averageEpisodeDurationMinutes: _readIntOrNull(
        json['average_duration_of_episode'],
      ),
    );
  }
}

class AniLibertyReleaseNameDto {
  const AniLibertyReleaseNameDto({
    required this.main,
    this.english,
    this.alternative,
  });

  final String main;
  final String? english;
  final String? alternative;

  factory AniLibertyReleaseNameDto.fromJson(Map<String, Object?> json) {
    final main = _readString(json['main']);
    final english = _readString(json['english']);

    if (main == null && english == null) {
      throw const FormatException('Release name is missing.');
    }

    return AniLibertyReleaseNameDto(
      main: main ?? english ?? '',
      english: english,
      alternative: _readString(json['alternative']),
    );
  }
}

class AniLibertyReleaseEpisodeDto {
  const AniLibertyReleaseEpisodeDto({required this.number, this.title});

  final int number;
  final String? title;

  factory AniLibertyReleaseEpisodeDto.fromJson(Map<String, Object?> json) {
    final ordinal =
        _readIntOrNull(json['sort_order']) ?? _readIntOrNull(json['ordinal']);
    if (ordinal == null) {
      throw const FormatException('Episode number is missing.');
    }

    return AniLibertyReleaseEpisodeDto(
      number: ordinal,
      title: _readString(json['name']) ?? _readString(json['name_english']),
    );
  }
}

class AniLibertyImageDto {
  const AniLibertyImageDto({this.src, this.preview, this.thumbnail});

  final String? src;
  final String? preview;
  final String? thumbnail;

  factory AniLibertyImageDto.fromJson(Map<String, Object?> json) {
    final optimized = _readObjectOrNull(json['optimized']);
    final source = optimized ?? json;

    return AniLibertyImageDto(
      src: _readString(source['src']),
      preview: _readString(source['preview']),
      thumbnail: _readString(source['thumbnail']),
    );
  }
}

class AniLibertyReleasePageDto {
  const AniLibertyReleasePageDto({
    required this.items,
    required this.page,
    required this.hasNextPage,
  });

  factory AniLibertyReleasePageDto.fromArray(
    List<AniLibertyReleaseDto> items, {
    required int page,
  }) {
    return AniLibertyReleasePageDto(
      items: items,
      page: page,
      hasNextPage: false,
    );
  }

  factory AniLibertyReleasePageDto.fromPaginatedJson(
    Map<String, Object?> json,
    int fallbackPage,
  ) {
    final data = _readList(json['data'], 'data');
    final meta = _readObjectOrNull(json['meta']);
    final pagination = _readObjectOrNull(meta?['pagination']);
    final page = _readIntOrNull(pagination?['current_page']) ?? fallbackPage;
    final totalPages = _readIntOrNull(pagination?['total_pages']);
    final links = _readObjectOrNull(pagination?['links']);
    final hasNextPage =
        _readString(links?['next']) != null ||
        (totalPages != null && page < totalPages);

    return AniLibertyReleasePageDto(
      items: data
          .map(
            (item) => AniLibertyReleaseDto.fromJson(_readObject(item, 'data')),
          )
          .toList(),
      page: page,
      hasNextPage: hasNextPage,
    );
  }

  final List<AniLibertyReleaseDto> items;
  final int page;
  final bool hasNextPage;
}

List<AniLibertyReleaseDto> aniLibertyReleaseDtosFromJsonArray(Object? data) {
  return _readList(data, 'releases')
      .map(
        (item) => AniLibertyReleaseDto.fromJson(_readObject(item, 'release')),
      )
      .toList();
}

Map<String, Object?> _readObject(Object? value, String fieldName) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw FormatException('$fieldName must be an object.');
}

Map<String, Object?>? _readObjectOrNull(Object? value) {
  if (value == null) {
    return null;
  }

  return _readObject(value, 'value');
}

List<Object?> _readList(Object? value, String fieldName) {
  if (value is List<Object?>) {
    return value;
  }

  throw FormatException('$fieldName must be a list.');
}

List<Object?>? _readListOrNull(Object? value) {
  if (value == null) {
    return null;
  }

  return _readList(value, 'value');
}

String? _readValueObjectString(Object? value) {
  return _readString(_readObjectOrNull(value)?['value']);
}

int? _readValueObjectInt(Object? value) {
  return _readIntOrNull(_readObjectOrNull(value)?['value']);
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

bool? _readBool(Object? value) {
  return value is bool ? value : null;
}

DateTime? _readDateTime(Object? value) {
  final rawValue = _readString(value);
  return rawValue == null ? null : DateTime.tryParse(rawValue);
}

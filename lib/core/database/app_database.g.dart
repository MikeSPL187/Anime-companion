// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibraryEntriesTable extends LibraryEntries
    with TableInfo<$LibraryEntriesTable, LibraryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<String> animeId = GeneratedColumn<String>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastInteractedAtMeta = const VerificationMeta(
    'lastInteractedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastInteractedAt =
      GeneratedColumn<DateTime>(
        'last_interacted_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    animeId,
    status,
    isFavorite,
    createdAt,
    updatedAt,
    lastInteractedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_interacted_at')) {
      context.handle(
        _lastInteractedAtMeta,
        lastInteractedAt.isAcceptableOrUnknown(
          data['last_interacted_at']!,
          _lastInteractedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastInteractedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animeId};
  @override
  LibraryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntry(
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anime_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastInteractedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interacted_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $LibraryEntriesTable createAlias(String alias) {
    return $LibraryEntriesTable(attachedDatabase, alias);
  }
}

class LibraryEntry extends DataClass implements Insertable<LibraryEntry> {
  final String animeId;
  final String status;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastInteractedAt;
  final String? note;
  const LibraryEntry({
    required this.animeId,
    required this.status,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.lastInteractedAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anime_id'] = Variable<String>(animeId);
    map['status'] = Variable<String>(status);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['last_interacted_at'] = Variable<DateTime>(lastInteractedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  LibraryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntriesCompanion(
      animeId: Value(animeId),
      status: Value(status),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastInteractedAt: Value(lastInteractedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory LibraryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntry(
      animeId: serializer.fromJson<String>(json['animeId']),
      status: serializer.fromJson<String>(json['status']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastInteractedAt: serializer.fromJson<DateTime>(json['lastInteractedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animeId': serializer.toJson<String>(animeId),
      'status': serializer.toJson<String>(status),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastInteractedAt': serializer.toJson<DateTime>(lastInteractedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  LibraryEntry copyWith({
    String? animeId,
    String? status,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastInteractedAt,
    Value<String?> note = const Value.absent(),
  }) => LibraryEntry(
    animeId: animeId ?? this.animeId,
    status: status ?? this.status,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastInteractedAt: lastInteractedAt ?? this.lastInteractedAt,
    note: note.present ? note.value : this.note,
  );
  LibraryEntry copyWithCompanion(LibraryEntriesCompanion data) {
    return LibraryEntry(
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      status: data.status.present ? data.status.value : this.status,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastInteractedAt: data.lastInteractedAt.present
          ? data.lastInteractedAt.value
          : this.lastInteractedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntry(')
          ..write('animeId: $animeId, ')
          ..write('status: $status, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastInteractedAt: $lastInteractedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    animeId,
    status,
    isFavorite,
    createdAt,
    updatedAt,
    lastInteractedAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntry &&
          other.animeId == this.animeId &&
          other.status == this.status &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastInteractedAt == this.lastInteractedAt &&
          other.note == this.note);
}

class LibraryEntriesCompanion extends UpdateCompanion<LibraryEntry> {
  final Value<String> animeId;
  final Value<String> status;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> lastInteractedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const LibraryEntriesCompanion({
    this.animeId = const Value.absent(),
    this.status = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastInteractedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntriesCompanion.insert({
    required String animeId,
    required String status,
    required bool isFavorite,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastInteractedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : animeId = Value(animeId),
       status = Value(status),
       isFavorite = Value(isFavorite),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastInteractedAt = Value(lastInteractedAt);
  static Insertable<LibraryEntry> custom({
    Expression<String>? animeId,
    Expression<String>? status,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastInteractedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animeId != null) 'anime_id': animeId,
      if (status != null) 'status': status,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastInteractedAt != null) 'last_interacted_at': lastInteractedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntriesCompanion copyWith({
    Value<String>? animeId,
    Value<String>? status,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? lastInteractedAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return LibraryEntriesCompanion(
      animeId: animeId ?? this.animeId,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastInteractedAt: lastInteractedAt ?? this.lastInteractedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animeId.present) {
      map['anime_id'] = Variable<String>(animeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastInteractedAt.present) {
      map['last_interacted_at'] = Variable<DateTime>(lastInteractedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntriesCompanion(')
          ..write('animeId: $animeId, ')
          ..write('status: $status, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastInteractedAt: $lastInteractedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchProgressEntriesTable extends WatchProgressEntries
    with TableInfo<$WatchProgressEntriesTable, WatchProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<String> animeId = GeneratedColumn<String>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchedEpisodesMeta = const VerificationMeta(
    'watchedEpisodes',
  );
  @override
  late final GeneratedColumn<int> watchedEpisodes = GeneratedColumn<int>(
    'watched_episodes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastWatchedEpisodeMeta =
      const VerificationMeta('lastWatchedEpisode');
  @override
  late final GeneratedColumn<int> lastWatchedEpisode = GeneratedColumn<int>(
    'last_watched_episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    animeId,
    watchedEpisodes,
    lastWatchedEpisode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('watched_episodes')) {
      context.handle(
        _watchedEpisodesMeta,
        watchedEpisodes.isAcceptableOrUnknown(
          data['watched_episodes']!,
          _watchedEpisodesMeta,
        ),
      );
    }
    if (data.containsKey('last_watched_episode')) {
      context.handle(
        _lastWatchedEpisodeMeta,
        lastWatchedEpisode.isAcceptableOrUnknown(
          data['last_watched_episode']!,
          _lastWatchedEpisodeMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animeId};
  @override
  WatchProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchProgressEntry(
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anime_id'],
      )!,
      watchedEpisodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watched_episodes'],
      )!,
      lastWatchedEpisode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_watched_episode'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WatchProgressEntriesTable createAlias(String alias) {
    return $WatchProgressEntriesTable(attachedDatabase, alias);
  }
}

class WatchProgressEntry extends DataClass
    implements Insertable<WatchProgressEntry> {
  final String animeId;
  final int watchedEpisodes;
  final int? lastWatchedEpisode;
  final DateTime updatedAt;
  const WatchProgressEntry({
    required this.animeId,
    required this.watchedEpisodes,
    this.lastWatchedEpisode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anime_id'] = Variable<String>(animeId);
    map['watched_episodes'] = Variable<int>(watchedEpisodes);
    if (!nullToAbsent || lastWatchedEpisode != null) {
      map['last_watched_episode'] = Variable<int>(lastWatchedEpisode);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WatchProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return WatchProgressEntriesCompanion(
      animeId: Value(animeId),
      watchedEpisodes: Value(watchedEpisodes),
      lastWatchedEpisode: lastWatchedEpisode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWatchedEpisode),
      updatedAt: Value(updatedAt),
    );
  }

  factory WatchProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchProgressEntry(
      animeId: serializer.fromJson<String>(json['animeId']),
      watchedEpisodes: serializer.fromJson<int>(json['watchedEpisodes']),
      lastWatchedEpisode: serializer.fromJson<int?>(json['lastWatchedEpisode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animeId': serializer.toJson<String>(animeId),
      'watchedEpisodes': serializer.toJson<int>(watchedEpisodes),
      'lastWatchedEpisode': serializer.toJson<int?>(lastWatchedEpisode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WatchProgressEntry copyWith({
    String? animeId,
    int? watchedEpisodes,
    Value<int?> lastWatchedEpisode = const Value.absent(),
    DateTime? updatedAt,
  }) => WatchProgressEntry(
    animeId: animeId ?? this.animeId,
    watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
    lastWatchedEpisode: lastWatchedEpisode.present
        ? lastWatchedEpisode.value
        : this.lastWatchedEpisode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WatchProgressEntry copyWithCompanion(WatchProgressEntriesCompanion data) {
    return WatchProgressEntry(
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      watchedEpisodes: data.watchedEpisodes.present
          ? data.watchedEpisodes.value
          : this.watchedEpisodes,
      lastWatchedEpisode: data.lastWatchedEpisode.present
          ? data.lastWatchedEpisode.value
          : this.lastWatchedEpisode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressEntry(')
          ..write('animeId: $animeId, ')
          ..write('watchedEpisodes: $watchedEpisodes, ')
          ..write('lastWatchedEpisode: $lastWatchedEpisode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(animeId, watchedEpisodes, lastWatchedEpisode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchProgressEntry &&
          other.animeId == this.animeId &&
          other.watchedEpisodes == this.watchedEpisodes &&
          other.lastWatchedEpisode == this.lastWatchedEpisode &&
          other.updatedAt == this.updatedAt);
}

class WatchProgressEntriesCompanion
    extends UpdateCompanion<WatchProgressEntry> {
  final Value<String> animeId;
  final Value<int> watchedEpisodes;
  final Value<int?> lastWatchedEpisode;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WatchProgressEntriesCompanion({
    this.animeId = const Value.absent(),
    this.watchedEpisodes = const Value.absent(),
    this.lastWatchedEpisode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchProgressEntriesCompanion.insert({
    required String animeId,
    this.watchedEpisodes = const Value.absent(),
    this.lastWatchedEpisode = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : animeId = Value(animeId),
       updatedAt = Value(updatedAt);
  static Insertable<WatchProgressEntry> custom({
    Expression<String>? animeId,
    Expression<int>? watchedEpisodes,
    Expression<int>? lastWatchedEpisode,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animeId != null) 'anime_id': animeId,
      if (watchedEpisodes != null) 'watched_episodes': watchedEpisodes,
      if (lastWatchedEpisode != null)
        'last_watched_episode': lastWatchedEpisode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchProgressEntriesCompanion copyWith({
    Value<String>? animeId,
    Value<int>? watchedEpisodes,
    Value<int?>? lastWatchedEpisode,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WatchProgressEntriesCompanion(
      animeId: animeId ?? this.animeId,
      watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
      lastWatchedEpisode: lastWatchedEpisode ?? this.lastWatchedEpisode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animeId.present) {
      map['anime_id'] = Variable<String>(animeId.value);
    }
    if (watchedEpisodes.present) {
      map['watched_episodes'] = Variable<int>(watchedEpisodes.value);
    }
    if (lastWatchedEpisode.present) {
      map['last_watched_episode'] = Variable<int>(lastWatchedEpisode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressEntriesCompanion(')
          ..write('animeId: $animeId, ')
          ..write('watchedEpisodes: $watchedEpisodes, ')
          ..write('lastWatchedEpisode: $lastWatchedEpisode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryEntriesTable extends SearchHistoryEntries
    with TableInfo<$SearchHistoryEntriesTable, SearchHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<DateTime> usedAt = GeneratedColumn<DateTime>(
    'used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [query, usedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(
        _usedAtMeta,
        usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_usedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  SearchHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryEntry(
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      usedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}used_at'],
      )!,
    );
  }

  @override
  $SearchHistoryEntriesTable createAlias(String alias) {
    return $SearchHistoryEntriesTable(attachedDatabase, alias);
  }
}

class SearchHistoryEntry extends DataClass
    implements Insertable<SearchHistoryEntry> {
  final String query;
  final DateTime usedAt;
  const SearchHistoryEntry({required this.query, required this.usedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['used_at'] = Variable<DateTime>(usedAt);
    return map;
  }

  SearchHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryEntriesCompanion(
      query: Value(query),
      usedAt: Value(usedAt),
    );
  }

  factory SearchHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryEntry(
      query: serializer.fromJson<String>(json['query']),
      usedAt: serializer.fromJson<DateTime>(json['usedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'usedAt': serializer.toJson<DateTime>(usedAt),
    };
  }

  SearchHistoryEntry copyWith({String? query, DateTime? usedAt}) =>
      SearchHistoryEntry(
        query: query ?? this.query,
        usedAt: usedAt ?? this.usedAt,
      );
  SearchHistoryEntry copyWithCompanion(SearchHistoryEntriesCompanion data) {
    return SearchHistoryEntry(
      query: data.query.present ? data.query.value : this.query,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntry(')
          ..write('query: $query, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(query, usedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryEntry &&
          other.query == this.query &&
          other.usedAt == this.usedAt);
}

class SearchHistoryEntriesCompanion
    extends UpdateCompanion<SearchHistoryEntry> {
  final Value<String> query;
  final Value<DateTime> usedAt;
  final Value<int> rowid;
  const SearchHistoryEntriesCompanion({
    this.query = const Value.absent(),
    this.usedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryEntriesCompanion.insert({
    required String query,
    required DateTime usedAt,
    this.rowid = const Value.absent(),
  }) : query = Value(query),
       usedAt = Value(usedAt);
  static Insertable<SearchHistoryEntry> custom({
    Expression<String>? query,
    Expression<DateTime>? usedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (usedAt != null) 'used_at': usedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryEntriesCompanion copyWith({
    Value<String>? query,
    Value<DateTime>? usedAt,
    Value<int>? rowid,
  }) {
    return SearchHistoryEntriesCompanion(
      query: query ?? this.query,
      usedAt: usedAt ?? this.usedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<DateTime>(usedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntriesCompanion(')
          ..write('query: $query, ')
          ..write('usedAt: $usedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSummaryListsTable extends CachedSummaryLists
    with TableInfo<$CachedSummaryListsTable, CachedSummaryList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSummaryListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_summary_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSummaryList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  CachedSummaryList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSummaryList(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedSummaryListsTable createAlias(String alias) {
    return $CachedSummaryListsTable(attachedDatabase, alias);
  }
}

class CachedSummaryList extends DataClass
    implements Insertable<CachedSummaryList> {
  final String cacheKey;
  final String payload;
  final DateTime fetchedAt;
  const CachedSummaryList({
    required this.cacheKey,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedSummaryListsCompanion toCompanion(bool nullToAbsent) {
    return CachedSummaryListsCompanion(
      cacheKey: Value(cacheKey),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedSummaryList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSummaryList(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedSummaryList copyWith({
    String? cacheKey,
    String? payload,
    DateTime? fetchedAt,
  }) => CachedSummaryList(
    cacheKey: cacheKey ?? this.cacheKey,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedSummaryList copyWithCompanion(CachedSummaryListsCompanion data) {
    return CachedSummaryList(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSummaryList(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSummaryList &&
          other.cacheKey == this.cacheKey &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CachedSummaryListsCompanion extends UpdateCompanion<CachedSummaryList> {
  final Value<String> cacheKey;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedSummaryListsCompanion({
    this.cacheKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSummaryListsCompanion.insert({
    required String cacheKey,
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedSummaryList> custom({
    Expression<String>? cacheKey,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSummaryListsCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedSummaryListsCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSummaryListsCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedReleaseDetailsTable extends CachedReleaseDetails
    with TableInfo<$CachedReleaseDetailsTable, CachedReleaseDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedReleaseDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<String> animeId = GeneratedColumn<String>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [animeId, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_release_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedReleaseDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animeId};
  @override
  CachedReleaseDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedReleaseDetail(
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anime_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedReleaseDetailsTable createAlias(String alias) {
    return $CachedReleaseDetailsTable(attachedDatabase, alias);
  }
}

class CachedReleaseDetail extends DataClass
    implements Insertable<CachedReleaseDetail> {
  final String animeId;
  final String payload;
  final DateTime fetchedAt;
  const CachedReleaseDetail({
    required this.animeId,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anime_id'] = Variable<String>(animeId);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedReleaseDetailsCompanion toCompanion(bool nullToAbsent) {
    return CachedReleaseDetailsCompanion(
      animeId: Value(animeId),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedReleaseDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedReleaseDetail(
      animeId: serializer.fromJson<String>(json['animeId']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animeId': serializer.toJson<String>(animeId),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedReleaseDetail copyWith({
    String? animeId,
    String? payload,
    DateTime? fetchedAt,
  }) => CachedReleaseDetail(
    animeId: animeId ?? this.animeId,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedReleaseDetail copyWithCompanion(CachedReleaseDetailsCompanion data) {
    return CachedReleaseDetail(
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedReleaseDetail(')
          ..write('animeId: $animeId, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(animeId, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedReleaseDetail &&
          other.animeId == this.animeId &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CachedReleaseDetailsCompanion
    extends UpdateCompanion<CachedReleaseDetail> {
  final Value<String> animeId;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedReleaseDetailsCompanion({
    this.animeId = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedReleaseDetailsCompanion.insert({
    required String animeId,
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : animeId = Value(animeId),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedReleaseDetail> custom({
    Expression<String>? animeId,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animeId != null) 'anime_id': animeId,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedReleaseDetailsCompanion copyWith({
    Value<String>? animeId,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedReleaseDetailsCompanion(
      animeId: animeId ?? this.animeId,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animeId.present) {
      map['anime_id'] = Variable<String>(animeId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedReleaseDetailsCompanion(')
          ..write('animeId: $animeId, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedFranchiseDataTable extends CachedFranchiseData
    with TableInfo<$CachedFranchiseDataTable, CachedFranchiseDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFranchiseDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [releaseId, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_franchise_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFranchiseDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {releaseId};
  @override
  CachedFranchiseDataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFranchiseDataData(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedFranchiseDataTable createAlias(String alias) {
    return $CachedFranchiseDataTable(attachedDatabase, alias);
  }
}

class CachedFranchiseDataData extends DataClass
    implements Insertable<CachedFranchiseDataData> {
  final String releaseId;
  final String payload;
  final DateTime fetchedAt;
  const CachedFranchiseDataData({
    required this.releaseId,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedFranchiseDataCompanion toCompanion(bool nullToAbsent) {
    return CachedFranchiseDataCompanion(
      releaseId: Value(releaseId),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedFranchiseDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFranchiseDataData(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedFranchiseDataData copyWith({
    String? releaseId,
    String? payload,
    DateTime? fetchedAt,
  }) => CachedFranchiseDataData(
    releaseId: releaseId ?? this.releaseId,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedFranchiseDataData copyWithCompanion(CachedFranchiseDataCompanion data) {
    return CachedFranchiseDataData(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFranchiseDataData(')
          ..write('releaseId: $releaseId, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(releaseId, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFranchiseDataData &&
          other.releaseId == this.releaseId &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CachedFranchiseDataCompanion
    extends UpdateCompanion<CachedFranchiseDataData> {
  final Value<String> releaseId;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedFranchiseDataCompanion({
    this.releaseId = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFranchiseDataCompanion.insert({
    required String releaseId,
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedFranchiseDataData> custom({
    Expression<String>? releaseId,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFranchiseDataCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedFranchiseDataCompanion(
      releaseId: releaseId ?? this.releaseId,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFranchiseDataCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedScheduleDataTable extends CachedScheduleData
    with TableInfo<$CachedScheduleDataTable, CachedScheduleDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedScheduleDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [scope, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_schedule_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedScheduleDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scope};
  @override
  CachedScheduleDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedScheduleDataData(
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedScheduleDataTable createAlias(String alias) {
    return $CachedScheduleDataTable(attachedDatabase, alias);
  }
}

class CachedScheduleDataData extends DataClass
    implements Insertable<CachedScheduleDataData> {
  final String scope;
  final String payload;
  final DateTime fetchedAt;
  const CachedScheduleDataData({
    required this.scope,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope'] = Variable<String>(scope);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedScheduleDataCompanion toCompanion(bool nullToAbsent) {
    return CachedScheduleDataCompanion(
      scope: Value(scope),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedScheduleDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedScheduleDataData(
      scope: serializer.fromJson<String>(json['scope']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scope': serializer.toJson<String>(scope),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedScheduleDataData copyWith({
    String? scope,
    String? payload,
    DateTime? fetchedAt,
  }) => CachedScheduleDataData(
    scope: scope ?? this.scope,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedScheduleDataData copyWithCompanion(CachedScheduleDataCompanion data) {
    return CachedScheduleDataData(
      scope: data.scope.present ? data.scope.value : this.scope,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedScheduleDataData(')
          ..write('scope: $scope, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scope, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedScheduleDataData &&
          other.scope == this.scope &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CachedScheduleDataCompanion
    extends UpdateCompanion<CachedScheduleDataData> {
  final Value<String> scope;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedScheduleDataCompanion({
    this.scope = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedScheduleDataCompanion.insert({
    required String scope,
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : scope = Value(scope),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedScheduleDataData> custom({
    Expression<String>? scope,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scope != null) 'scope': scope,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedScheduleDataCompanion copyWith({
    Value<String>? scope,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedScheduleDataCompanion(
      scope: scope ?? this.scope,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedScheduleDataCompanion(')
          ..write('scope: $scope, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryEntriesTable libraryEntries = $LibraryEntriesTable(this);
  late final $WatchProgressEntriesTable watchProgressEntries =
      $WatchProgressEntriesTable(this);
  late final $SearchHistoryEntriesTable searchHistoryEntries =
      $SearchHistoryEntriesTable(this);
  late final $CachedSummaryListsTable cachedSummaryLists =
      $CachedSummaryListsTable(this);
  late final $CachedReleaseDetailsTable cachedReleaseDetails =
      $CachedReleaseDetailsTable(this);
  late final $CachedFranchiseDataTable cachedFranchiseData =
      $CachedFranchiseDataTable(this);
  late final $CachedScheduleDataTable cachedScheduleData =
      $CachedScheduleDataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryEntries,
    watchProgressEntries,
    searchHistoryEntries,
    cachedSummaryLists,
    cachedReleaseDetails,
    cachedFranchiseData,
    cachedScheduleData,
  ];
}

typedef $$LibraryEntriesTableCreateCompanionBuilder =
    LibraryEntriesCompanion Function({
      required String animeId,
      required String status,
      required bool isFavorite,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime lastInteractedAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$LibraryEntriesTableUpdateCompanionBuilder =
    LibraryEntriesCompanion Function({
      Value<String> animeId,
      Value<String> status,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> lastInteractedAt,
      Value<String?> note,
      Value<int> rowid,
    });

class $$LibraryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$LibraryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryEntriesTable,
          LibraryEntry,
          $$LibraryEntriesTableFilterComposer,
          $$LibraryEntriesTableOrderingComposer,
          $$LibraryEntriesTableAnnotationComposer,
          $$LibraryEntriesTableCreateCompanionBuilder,
          $$LibraryEntriesTableUpdateCompanionBuilder,
          (
            LibraryEntry,
            BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry>,
          ),
          LibraryEntry,
          PrefetchHooks Function()
        > {
  $$LibraryEntriesTableTableManager(
    _$AppDatabase db,
    $LibraryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> animeId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> lastInteractedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion(
                animeId: animeId,
                status: status,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastInteractedAt: lastInteractedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String animeId,
                required String status,
                required bool isFavorite,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime lastInteractedAt,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion.insert(
                animeId: animeId,
                status: status,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastInteractedAt: lastInteractedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryEntriesTable,
      LibraryEntry,
      $$LibraryEntriesTableFilterComposer,
      $$LibraryEntriesTableOrderingComposer,
      $$LibraryEntriesTableAnnotationComposer,
      $$LibraryEntriesTableCreateCompanionBuilder,
      $$LibraryEntriesTableUpdateCompanionBuilder,
      (
        LibraryEntry,
        BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry>,
      ),
      LibraryEntry,
      PrefetchHooks Function()
    >;
typedef $$WatchProgressEntriesTableCreateCompanionBuilder =
    WatchProgressEntriesCompanion Function({
      required String animeId,
      Value<int> watchedEpisodes,
      Value<int?> lastWatchedEpisode,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WatchProgressEntriesTableUpdateCompanionBuilder =
    WatchProgressEntriesCompanion Function({
      Value<String> animeId,
      Value<int> watchedEpisodes,
      Value<int?> lastWatchedEpisode,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WatchProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WatchProgressEntriesTable> {
  $$WatchProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get watchedEpisodes => $composableBuilder(
    column: $table.watchedEpisodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWatchedEpisode => $composableBuilder(
    column: $table.lastWatchedEpisode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchProgressEntriesTable> {
  $$WatchProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get watchedEpisodes => $composableBuilder(
    column: $table.watchedEpisodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWatchedEpisode => $composableBuilder(
    column: $table.lastWatchedEpisode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchProgressEntriesTable> {
  $$WatchProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<int> get watchedEpisodes => $composableBuilder(
    column: $table.watchedEpisodes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastWatchedEpisode => $composableBuilder(
    column: $table.lastWatchedEpisode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WatchProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchProgressEntriesTable,
          WatchProgressEntry,
          $$WatchProgressEntriesTableFilterComposer,
          $$WatchProgressEntriesTableOrderingComposer,
          $$WatchProgressEntriesTableAnnotationComposer,
          $$WatchProgressEntriesTableCreateCompanionBuilder,
          $$WatchProgressEntriesTableUpdateCompanionBuilder,
          (
            WatchProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $WatchProgressEntriesTable,
              WatchProgressEntry
            >,
          ),
          WatchProgressEntry,
          PrefetchHooks Function()
        > {
  $$WatchProgressEntriesTableTableManager(
    _$AppDatabase db,
    $WatchProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WatchProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> animeId = const Value.absent(),
                Value<int> watchedEpisodes = const Value.absent(),
                Value<int?> lastWatchedEpisode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchProgressEntriesCompanion(
                animeId: animeId,
                watchedEpisodes: watchedEpisodes,
                lastWatchedEpisode: lastWatchedEpisode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String animeId,
                Value<int> watchedEpisodes = const Value.absent(),
                Value<int?> lastWatchedEpisode = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WatchProgressEntriesCompanion.insert(
                animeId: animeId,
                watchedEpisodes: watchedEpisodes,
                lastWatchedEpisode: lastWatchedEpisode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchProgressEntriesTable,
      WatchProgressEntry,
      $$WatchProgressEntriesTableFilterComposer,
      $$WatchProgressEntriesTableOrderingComposer,
      $$WatchProgressEntriesTableAnnotationComposer,
      $$WatchProgressEntriesTableCreateCompanionBuilder,
      $$WatchProgressEntriesTableUpdateCompanionBuilder,
      (
        WatchProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $WatchProgressEntriesTable,
          WatchProgressEntry
        >,
      ),
      WatchProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryEntriesTableCreateCompanionBuilder =
    SearchHistoryEntriesCompanion Function({
      required String query,
      required DateTime usedAt,
      Value<int> rowid,
    });
typedef $$SearchHistoryEntriesTableUpdateCompanionBuilder =
    SearchHistoryEntriesCompanion Function({
      Value<String> query,
      Value<DateTime> usedAt,
      Value<int> rowid,
    });

class $$SearchHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);
}

class $$SearchHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryEntriesTable,
          SearchHistoryEntry,
          $$SearchHistoryEntriesTableFilterComposer,
          $$SearchHistoryEntriesTableOrderingComposer,
          $$SearchHistoryEntriesTableAnnotationComposer,
          $$SearchHistoryEntriesTableCreateCompanionBuilder,
          $$SearchHistoryEntriesTableUpdateCompanionBuilder,
          (
            SearchHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryEntriesTable,
              SearchHistoryEntry
            >,
          ),
          SearchHistoryEntry,
          PrefetchHooks Function()
        > {
  $$SearchHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $SearchHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SearchHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> query = const Value.absent(),
                Value<DateTime> usedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryEntriesCompanion(
                query: query,
                usedAt: usedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String query,
                required DateTime usedAt,
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryEntriesCompanion.insert(
                query: query,
                usedAt: usedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryEntriesTable,
      SearchHistoryEntry,
      $$SearchHistoryEntriesTableFilterComposer,
      $$SearchHistoryEntriesTableOrderingComposer,
      $$SearchHistoryEntriesTableAnnotationComposer,
      $$SearchHistoryEntriesTableCreateCompanionBuilder,
      $$SearchHistoryEntriesTableUpdateCompanionBuilder,
      (
        SearchHistoryEntry,
        BaseReferences<
          _$AppDatabase,
          $SearchHistoryEntriesTable,
          SearchHistoryEntry
        >,
      ),
      SearchHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedSummaryListsTableCreateCompanionBuilder =
    CachedSummaryListsCompanion Function({
      required String cacheKey,
      required String payload,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedSummaryListsTableUpdateCompanionBuilder =
    CachedSummaryListsCompanion Function({
      Value<String> cacheKey,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedSummaryListsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSummaryListsTable> {
  $$CachedSummaryListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSummaryListsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSummaryListsTable> {
  $$CachedSummaryListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSummaryListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSummaryListsTable> {
  $$CachedSummaryListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedSummaryListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSummaryListsTable,
          CachedSummaryList,
          $$CachedSummaryListsTableFilterComposer,
          $$CachedSummaryListsTableOrderingComposer,
          $$CachedSummaryListsTableAnnotationComposer,
          $$CachedSummaryListsTableCreateCompanionBuilder,
          $$CachedSummaryListsTableUpdateCompanionBuilder,
          (
            CachedSummaryList,
            BaseReferences<
              _$AppDatabase,
              $CachedSummaryListsTable,
              CachedSummaryList
            >,
          ),
          CachedSummaryList,
          PrefetchHooks Function()
        > {
  $$CachedSummaryListsTableTableManager(
    _$AppDatabase db,
    $CachedSummaryListsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSummaryListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSummaryListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSummaryListsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSummaryListsCompanion(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String payload,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSummaryListsCompanion.insert(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSummaryListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSummaryListsTable,
      CachedSummaryList,
      $$CachedSummaryListsTableFilterComposer,
      $$CachedSummaryListsTableOrderingComposer,
      $$CachedSummaryListsTableAnnotationComposer,
      $$CachedSummaryListsTableCreateCompanionBuilder,
      $$CachedSummaryListsTableUpdateCompanionBuilder,
      (
        CachedSummaryList,
        BaseReferences<
          _$AppDatabase,
          $CachedSummaryListsTable,
          CachedSummaryList
        >,
      ),
      CachedSummaryList,
      PrefetchHooks Function()
    >;
typedef $$CachedReleaseDetailsTableCreateCompanionBuilder =
    CachedReleaseDetailsCompanion Function({
      required String animeId,
      required String payload,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedReleaseDetailsTableUpdateCompanionBuilder =
    CachedReleaseDetailsCompanion Function({
      Value<String> animeId,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedReleaseDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedReleaseDetailsTable> {
  $$CachedReleaseDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedReleaseDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedReleaseDetailsTable> {
  $$CachedReleaseDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedReleaseDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedReleaseDetailsTable> {
  $$CachedReleaseDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedReleaseDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedReleaseDetailsTable,
          CachedReleaseDetail,
          $$CachedReleaseDetailsTableFilterComposer,
          $$CachedReleaseDetailsTableOrderingComposer,
          $$CachedReleaseDetailsTableAnnotationComposer,
          $$CachedReleaseDetailsTableCreateCompanionBuilder,
          $$CachedReleaseDetailsTableUpdateCompanionBuilder,
          (
            CachedReleaseDetail,
            BaseReferences<
              _$AppDatabase,
              $CachedReleaseDetailsTable,
              CachedReleaseDetail
            >,
          ),
          CachedReleaseDetail,
          PrefetchHooks Function()
        > {
  $$CachedReleaseDetailsTableTableManager(
    _$AppDatabase db,
    $CachedReleaseDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedReleaseDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedReleaseDetailsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedReleaseDetailsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> animeId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedReleaseDetailsCompanion(
                animeId: animeId,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String animeId,
                required String payload,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedReleaseDetailsCompanion.insert(
                animeId: animeId,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedReleaseDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedReleaseDetailsTable,
      CachedReleaseDetail,
      $$CachedReleaseDetailsTableFilterComposer,
      $$CachedReleaseDetailsTableOrderingComposer,
      $$CachedReleaseDetailsTableAnnotationComposer,
      $$CachedReleaseDetailsTableCreateCompanionBuilder,
      $$CachedReleaseDetailsTableUpdateCompanionBuilder,
      (
        CachedReleaseDetail,
        BaseReferences<
          _$AppDatabase,
          $CachedReleaseDetailsTable,
          CachedReleaseDetail
        >,
      ),
      CachedReleaseDetail,
      PrefetchHooks Function()
    >;
typedef $$CachedFranchiseDataTableCreateCompanionBuilder =
    CachedFranchiseDataCompanion Function({
      required String releaseId,
      required String payload,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedFranchiseDataTableUpdateCompanionBuilder =
    CachedFranchiseDataCompanion Function({
      Value<String> releaseId,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedFranchiseDataTableFilterComposer
    extends Composer<_$AppDatabase, $CachedFranchiseDataTable> {
  $$CachedFranchiseDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedFranchiseDataTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedFranchiseDataTable> {
  $$CachedFranchiseDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedFranchiseDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedFranchiseDataTable> {
  $$CachedFranchiseDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedFranchiseDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedFranchiseDataTable,
          CachedFranchiseDataData,
          $$CachedFranchiseDataTableFilterComposer,
          $$CachedFranchiseDataTableOrderingComposer,
          $$CachedFranchiseDataTableAnnotationComposer,
          $$CachedFranchiseDataTableCreateCompanionBuilder,
          $$CachedFranchiseDataTableUpdateCompanionBuilder,
          (
            CachedFranchiseDataData,
            BaseReferences<
              _$AppDatabase,
              $CachedFranchiseDataTable,
              CachedFranchiseDataData
            >,
          ),
          CachedFranchiseDataData,
          PrefetchHooks Function()
        > {
  $$CachedFranchiseDataTableTableManager(
    _$AppDatabase db,
    $CachedFranchiseDataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFranchiseDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFranchiseDataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedFranchiseDataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFranchiseDataCompanion(
                releaseId: releaseId,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String payload,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedFranchiseDataCompanion.insert(
                releaseId: releaseId,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedFranchiseDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedFranchiseDataTable,
      CachedFranchiseDataData,
      $$CachedFranchiseDataTableFilterComposer,
      $$CachedFranchiseDataTableOrderingComposer,
      $$CachedFranchiseDataTableAnnotationComposer,
      $$CachedFranchiseDataTableCreateCompanionBuilder,
      $$CachedFranchiseDataTableUpdateCompanionBuilder,
      (
        CachedFranchiseDataData,
        BaseReferences<
          _$AppDatabase,
          $CachedFranchiseDataTable,
          CachedFranchiseDataData
        >,
      ),
      CachedFranchiseDataData,
      PrefetchHooks Function()
    >;
typedef $$CachedScheduleDataTableCreateCompanionBuilder =
    CachedScheduleDataCompanion Function({
      required String scope,
      required String payload,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedScheduleDataTableUpdateCompanionBuilder =
    CachedScheduleDataCompanion Function({
      Value<String> scope,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedScheduleDataTableFilterComposer
    extends Composer<_$AppDatabase, $CachedScheduleDataTable> {
  $$CachedScheduleDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedScheduleDataTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedScheduleDataTable> {
  $$CachedScheduleDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedScheduleDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedScheduleDataTable> {
  $$CachedScheduleDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedScheduleDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedScheduleDataTable,
          CachedScheduleDataData,
          $$CachedScheduleDataTableFilterComposer,
          $$CachedScheduleDataTableOrderingComposer,
          $$CachedScheduleDataTableAnnotationComposer,
          $$CachedScheduleDataTableCreateCompanionBuilder,
          $$CachedScheduleDataTableUpdateCompanionBuilder,
          (
            CachedScheduleDataData,
            BaseReferences<
              _$AppDatabase,
              $CachedScheduleDataTable,
              CachedScheduleDataData
            >,
          ),
          CachedScheduleDataData,
          PrefetchHooks Function()
        > {
  $$CachedScheduleDataTableTableManager(
    _$AppDatabase db,
    $CachedScheduleDataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedScheduleDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedScheduleDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedScheduleDataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> scope = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedScheduleDataCompanion(
                scope: scope,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scope,
                required String payload,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedScheduleDataCompanion.insert(
                scope: scope,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedScheduleDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedScheduleDataTable,
      CachedScheduleDataData,
      $$CachedScheduleDataTableFilterComposer,
      $$CachedScheduleDataTableOrderingComposer,
      $$CachedScheduleDataTableAnnotationComposer,
      $$CachedScheduleDataTableCreateCompanionBuilder,
      $$CachedScheduleDataTableUpdateCompanionBuilder,
      (
        CachedScheduleDataData,
        BaseReferences<
          _$AppDatabase,
          $CachedScheduleDataTable,
          CachedScheduleDataData
        >,
      ),
      CachedScheduleDataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryEntriesTableTableManager get libraryEntries =>
      $$LibraryEntriesTableTableManager(_db, _db.libraryEntries);
  $$WatchProgressEntriesTableTableManager get watchProgressEntries =>
      $$WatchProgressEntriesTableTableManager(_db, _db.watchProgressEntries);
  $$SearchHistoryEntriesTableTableManager get searchHistoryEntries =>
      $$SearchHistoryEntriesTableTableManager(_db, _db.searchHistoryEntries);
  $$CachedSummaryListsTableTableManager get cachedSummaryLists =>
      $$CachedSummaryListsTableTableManager(_db, _db.cachedSummaryLists);
  $$CachedReleaseDetailsTableTableManager get cachedReleaseDetails =>
      $$CachedReleaseDetailsTableTableManager(_db, _db.cachedReleaseDetails);
  $$CachedFranchiseDataTableTableManager get cachedFranchiseData =>
      $$CachedFranchiseDataTableTableManager(_db, _db.cachedFranchiseData);
  $$CachedScheduleDataTableTableManager get cachedScheduleData =>
      $$CachedScheduleDataTableTableManager(_db, _db.cachedScheduleData);
}

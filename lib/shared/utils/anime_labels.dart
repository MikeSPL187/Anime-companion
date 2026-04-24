import '../../domain/enums/enums.dart';
import '../../domain/models/library_presentation_snapshot.dart';
import '../../domain/models/watch_progress.dart';

String libraryStatusLabel(LibraryStatus? status, {String fallback = ''}) {
  return switch (status) {
    LibraryStatus.watching => 'Смотрю',
    LibraryStatus.planned => 'Хочу посмотреть',
    LibraryStatus.completed => 'Просмотрено',
    LibraryStatus.postponed => 'Отложено',
    LibraryStatus.dropped => 'Брошено',
    null => fallback,
  };
}

String animeTypeLabel(AnimeType? type, {String fallback = ''}) {
  return switch (type) {
    AnimeType.tv => 'ТВ',
    AnimeType.movie => 'Фильм',
    AnimeType.ova => 'OVA',
    AnimeType.ona => 'ONA',
    AnimeType.special => 'Спешл',
    AnimeType.unknown => 'Тип неизвестен',
    null => fallback,
  };
}

String animeSeasonLabel(AnimeSeason? season, {String fallback = ''}) {
  return switch (season) {
    AnimeSeason.winter => 'Зима',
    AnimeSeason.spring => 'Весна',
    AnimeSeason.summer => 'Лето',
    AnimeSeason.fall => 'Осень',
    null => fallback,
  };
}

String publishDayLabel(PublishDay? day, {String fallback = ''}) {
  return switch (day) {
    PublishDay.monday => 'Понедельник',
    PublishDay.tuesday => 'Вторник',
    PublishDay.wednesday => 'Среда',
    PublishDay.thursday => 'Четверг',
    PublishDay.friday => 'Пятница',
    PublishDay.saturday => 'Суббота',
    PublishDay.sunday => 'Воскресенье',
    null => fallback,
  };
}

String ageRatingLabel(AgeRating? rating, {String fallback = ''}) {
  return switch (rating) {
    AgeRating.g => '0+',
    AgeRating.pg => '6+',
    AgeRating.pg13 => '12+',
    AgeRating.r => '16+',
    AgeRating.rPlus => '18+',
    AgeRating.rx => '18+',
    AgeRating.unknown => 'Возраст неизвестен',
    null => fallback,
  };
}

String popularityLabel(int favoritesCount) {
  return '♥ $favoritesCount';
}

String progressLabel(int watchedEpisodes, int? episodesTotal) {
  return episodesTotal == null
      ? 'Просмотрено: $watchedEpisodes'
      : 'Прогресс: $watchedEpisodes/$episodesTotal';
}

String watchProgressLabel(WatchProgress progress, int? episodesTotal) {
  return progressLabel(progress.watchedEpisodes, episodesTotal);
}

String? episodesProgressLabel(int? episodesTotal, WatchProgress? progress) {
  final watched = progress?.watchedEpisodes;
  if (watched != null) {
    return progressLabel(watched, episodesTotal);
  }

  if (episodesTotal != null) {
    return 'Эпизодов: $episodesTotal';
  }

  return null;
}

String libraryEntryTitle(
  String animeId,
  LibraryPresentationSnapshot? snapshot,
) {
  final title = snapshot?.title.trim();
  return title == null || title.isEmpty ? 'Релиз #$animeId' : title;
}

String snapshotTitleOr(String fallback, LibraryPresentationSnapshot? snapshot) {
  final title = snapshot?.title.trim();
  return title == null || title.isEmpty ? fallback : title;
}

String? snapshotPosterOr(
  String? fallback,
  LibraryPresentationSnapshot? snapshot,
) {
  final poster = snapshot?.posterUrl?.trim();
  if (poster != null && poster.isNotEmpty) {
    return poster;
  }

  final fallbackPoster = fallback?.trim();
  return fallbackPoster == null || fallbackPoster.isEmpty
      ? null
      : fallbackPoster;
}

String dateLabel(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}

String dateTimeLabel(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day.$month $hour:$minute';
}

String freshnessLabel(DateTime? fetchedAt, {DateTime? now}) {
  if (fetchedAt == null) {
    return 'Расписание ещё не загружалось';
  }

  final referenceTime = now ?? DateTime.now();
  final difference = referenceTime.difference(fetchedAt);
  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes <= 0 ? 1 : difference.inMinutes;
    return 'Обновлено $minutes мин назад';
  }

  return 'Обновлено ${difference.inHours} ч назад';
}

String scheduleFreshnessLabel({
  required DateTime? fetchedAt,
  required bool isStale,
  DateTime? now,
}) {
  final label = freshnessLabel(fetchedAt, now: now);
  return fetchedAt != null && isStale
      ? 'Данные могут устареть · $label'
      : label;
}

String scheduleRefreshFailureLabel(DateTime? cachedDataFetchedAt) {
  if (cachedDataFetchedAt == null) {
    return 'Не удалось обновить расписание';
  }

  return 'Не удалось обновить. Данные от ${dateTimeLabel(cachedDataFetchedAt)}';
}

import 'package:ani_app/domain/enums/enums.dart';
import 'package:ani_app/domain/models/library_presentation_snapshot.dart';
import 'package:ani_app/shared/utils/anime_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats shared personal presentation labels', () {
    expect(libraryStatusLabel(LibraryStatus.watching), 'Смотрю');
    expect(animeTypeLabel(AnimeType.movie), 'Фильм');
    expect(publishDayLabel(PublishDay.thursday), 'Четверг');
    expect(popularityLabel(42), '♥ 42');
    expect(progressLabel(3, 12), 'Прогресс: 3/12');
    expect(progressLabel(3, null), 'Просмотрено: 3');
  });

  test('resolves snapshot title and poster with honest fallback', () {
    final snapshot = LibraryPresentationSnapshot(
      animeId: '413',
      title: 'Наруто',
      posterUrl: 'https://example.test/poster.webp',
      snapshotSavedAt: DateTime(2026, 4, 9),
    );

    expect(libraryEntryTitle('413', snapshot), 'Наруто');
    expect(snapshotTitleOr('Расписание 413', snapshot), 'Наруто');
    expect(
      snapshotPosterOr('https://example.test/fallback.webp', snapshot),
      'https://example.test/poster.webp',
    );
    expect(libraryEntryTitle('999', null), 'Релиз #999');
    expect(snapshotPosterOr('', null), isNull);
  });

  test('formats freshness and stale refresh labels consistently', () {
    final now = DateTime(2026, 4, 9, 12);
    final fetchedAt = DateTime(2026, 4, 9, 10);

    expect(freshnessLabel(fetchedAt, now: now), 'Обновлено 2 ч назад');
    expect(
      scheduleFreshnessLabel(fetchedAt: fetchedAt, isStale: true, now: now),
      'Данные могут устареть · Обновлено 2 ч назад',
    );
    expect(
      scheduleRefreshFailureLabel(DateTime(2026, 4, 9, 8, 5)),
      'Не удалось обновить. Данные от 09.04 08:05',
    );
  });
}

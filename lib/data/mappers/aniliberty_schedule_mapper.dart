import '../../domain/models/schedule_item.dart';
import '../dtos/aniliberty_schedule_dto.dart';
import 'aniliberty_release_mapper.dart';

extension AniLibertyScheduleNowMapper on AniLibertyScheduleNowDto {
  List<ScheduleItem> toTodayScheduleItems() {
    return today.toScheduleItems();
  }
}

extension AniLibertyScheduleWeekMapper on AniLibertyScheduleWeekDto {
  List<ScheduleItem> toScheduleItems() {
    return items.toScheduleItems();
  }
}

extension on List<AniLibertyScheduleEntryDto> {
  List<ScheduleItem> toScheduleItems() {
    return map((item) => item.toScheduleItem()).nonNulls.toList();
  }
}

extension on AniLibertyScheduleEntryDto {
  ScheduleItem? toScheduleItem() {
    final summary = release.toAnimeSummary();
    final publishDay = summary.publishDay;
    if (publishDay == null) {
      return null;
    }

    return ScheduleItem(
      releaseId: summary.id,
      title: summary.title,
      posterUrl: summary.posterUrl,
      publishDay: publishDay,
      isOngoing: summary.isOngoing,
    );
  }
}

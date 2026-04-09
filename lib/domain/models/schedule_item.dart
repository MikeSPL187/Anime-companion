import '../enums/enums.dart';

class ScheduleItem {
  const ScheduleItem({
    required this.releaseId,
    required this.title,
    required this.posterUrl,
    required this.publishDay,
    required this.isOngoing,
  });

  final String releaseId;
  final String title;
  final String posterUrl;
  final PublishDay publishDay;
  final bool isOngoing;
}

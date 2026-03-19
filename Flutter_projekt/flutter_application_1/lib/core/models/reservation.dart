import 'room.dart';

/// Status rezervacije prema PROJECT_CONTEXT
enum ReservationStatus {
  pending,
  approved,
  rejected,
}

/// Model rezervacije za prikaz u "Moje rezervacije"
class Reservation {
  final String id;
  final Room room;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final double totalPrice;

  Reservation({
    required this.id,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
  });

  String get formattedDate =>
      '${startTime.day.toString().padLeft(2, '0')}.${startTime.month.toString().padLeft(2, '0')}.${startTime.year}';

  String get formattedTimeRange =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - '
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  String get statusLabel {
    switch (status) {
      case ReservationStatus.pending:
        return 'Na čekanju';
      case ReservationStatus.approved:
        return 'Odobreno';
      case ReservationStatus.rejected:
        return 'Odbijeno';
    }
  }
}

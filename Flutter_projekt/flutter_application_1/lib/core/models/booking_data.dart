import 'room.dart';

/// Podaci za rezervaciju u tijeku
class BookingData {
  final Room room;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int durationMinutes;

  BookingData({
    required this.room,
    required this.date,
    this.startHour = 0,
    this.startMinute = 0,
    this.durationMinutes = 60,
  });

  BookingData copyWith({
    Room? room,
    DateTime? date,
    int? startHour,
    int? startMinute,
    int? durationMinutes,
  }) =>
      BookingData(
        room: room ?? this.room,
        date: date ?? this.date,
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );

  double get totalPrice =>
      room.pricePerMinute * durationMinutes;

  String get formattedStartTime =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get formattedDuration =>
      '${durationMinutes ~/ 60}:${(durationMinutes % 60).toString().padLeft(2, '0')}';
}

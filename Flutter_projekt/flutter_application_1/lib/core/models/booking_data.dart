import 'room.dart';

class BookingTimeRange {
  final int startHour;
  final int startMinute;
  final int durationMinutes;

  const BookingTimeRange({
    required this.startHour,
    this.startMinute = 0,
    required this.durationMinutes,
  });

  int get endHour => startHour + ((startMinute + durationMinutes) ~/ 60);

  int get endMinute => (startMinute + durationMinutes) % 60;

  String get formattedStartTime =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get formattedEndTime =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';

  String get formattedDuration =>
      '${durationMinutes ~/ 60}:${(durationMinutes % 60).toString().padLeft(2, '0')}';
}

/// Podaci za rezervaciju u tijeku
class BookingData {
  final Room room;
  final DateTime date;
  final List<BookingTimeRange> timeRanges;

  BookingData({
    required this.room,
    required this.date,
    int startHour = 0,
    int startMinute = 0,
    int durationMinutes = 60,
    List<BookingTimeRange>? timeRanges,
  }) : timeRanges =
           timeRanges ??
           [
             BookingTimeRange(
               startHour: startHour,
               startMinute: startMinute,
               durationMinutes: durationMinutes,
             ),
           ];

  BookingTimeRange get firstRange => timeRanges.first;

  BookingData copyWith({
    Room? room,
    DateTime? date,
    List<BookingTimeRange>? timeRanges,
  }) => BookingData(
    room: room ?? this.room,
    date: date ?? this.date,
    timeRanges: timeRanges ?? this.timeRanges,
  );

  int get durationMinutes =>
      timeRanges.fold(0, (total, range) => total + range.durationMinutes);

  double get totalPrice => room.pricePerMinute * durationMinutes;

  double get pricePerHour => room.pricePerMinute * 60;

  String get formattedStartTime => firstRange.formattedStartTime;

  String get formattedTimeRanges =>
      timeRanges.map((range) => range.formattedTimeRange).join(', ');

  String get formattedDuration =>
      '${durationMinutes ~/ 60}:${(durationMinutes % 60).toString().padLeft(2, '0')}';
}

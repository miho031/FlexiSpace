import '../../../core/models/booking_data.dart';
import '../../../core/models/reservation.dart';
import '../../../core/models/room.dart';
import '../domain/reservation_repository.dart';

/// Mock implementacija - simulira rezervacije dok Supabase nije dostupan.
/// Koristi static listu da rezervacije ostaju u memoriji tijekom sesije.
class MockReservationRepository implements ReservationRepository {
  static final List<Reservation> _mockReservations = [];
  static int _idCounter = 1;

  @override
  Future<List<Reservation>> createReservations(
    BookingData bookingData,
    String userId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final reservations = bookingData.timeRanges.map((range) {
      final startTime = DateTime(
        bookingData.date.year,
        bookingData.date.month,
        bookingData.date.day,
        range.startHour,
        range.startMinute,
      );
      final endTime = startTime.add(Duration(minutes: range.durationMinutes));

      return Reservation(
        id: 'mock_${_idCounter++}',
        room: bookingData.room,
        startTime: startTime,
        endTime: endTime,
        status: ReservationStatus.pending,
        totalPrice:
            bookingData.room.pricePerMinute *
            endTime.difference(startTime).inMinutes,
      );
    }).toList();

    _mockReservations.addAll(reservations);
    return reservations;
  }

  @override
  Future<List<Reservation>> getMyReservations(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (_mockReservations.isEmpty) {
      return _getDefaultMockReservations();
    }
    return List.from(_mockReservations);
  }

  @override
  Future<List<ReservedInterval>> getReservedIntervals({
    required String spaceId,
    required DateTime date,
    required String userId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockReservations
        .where(
          (reservation) =>
              reservation.room.id == spaceId &&
              reservation.status != ReservationStatus.rejected &&
              reservation.startTime.year == date.year &&
              reservation.startTime.month == date.month &&
              reservation.startTime.day == date.day,
        )
        .map(
          (reservation) => ReservedInterval(
            startTime: reservation.startTime,
            endTime: reservation.endTime,
            blocksBooking: true,
          ),
        )
        .toList();
  }

  List<Reservation> _getDefaultMockReservations() {
    final now = DateTime.now();
    return [
      Reservation(
        id: 'mock_1',
        room: Room(
          id: '1',
          name: 'Orlando sala',
          imagePath: '',
          address: 'Ul. od Puča 12',
          pricePerMinute: 0.08,
          capacity: 30,
          hasWifi: true,
          hasWater: true,
        ),
        startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 11, 0),
        status: ReservationStatus.pending,
        totalPrice: 4.80,
      ),
      Reservation(
        id: 'mock_2',
        room: Room(
          id: '3',
          name: 'Study corner',
          imagePath: '',
          address: 'Ul. Knjižnična 3',
          pricePerMinute: 0.04,
          capacity: 16,
          hasWifi: true,
          hasWater: false,
        ),
        startTime: DateTime(now.year, now.month, now.day - 2, 14, 0),
        endTime: DateTime(now.year, now.month, now.day - 2, 16, 0),
        status: ReservationStatus.approved,
        totalPrice: 4.80,
      ),
    ];
  }
}

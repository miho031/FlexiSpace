import '../../../core/models/booking_data.dart';
import '../../../core/models/reservation.dart';

class ReservedInterval {
  final DateTime startTime;
  final DateTime endTime;
  final bool blocksBooking;

  const ReservedInterval({
    required this.startTime,
    required this.endTime,
    required this.blocksBooking,
  });

  bool overlaps(DateTime start, DateTime end) =>
      start.isBefore(endTime) && end.isAfter(startTime);
}

/// Sucelje za pristup rezervacijama.
abstract class ReservationRepository {
  /// Kreira jednu ili vise rezervacija (status: pending).
  Future<List<Reservation>> createReservations(
    BookingData bookingData,
    String userId,
  );

  /// Dohvaca rezervacije trenutnog korisnika.
  Future<List<Reservation>> getMyReservations(String userId);

  /// Dohvaca termine koji blokiraju odabir za dan i prostoriju.
  Future<List<ReservedInterval>> getReservedIntervals({
    required String spaceId,
    required DateTime date,
    required String userId,
  });
}

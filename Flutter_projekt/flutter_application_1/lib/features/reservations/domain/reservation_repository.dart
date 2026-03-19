import '../../../core/models/booking_data.dart';
import '../../../core/models/reservation.dart';

/// Sučelje za pristup rezervacijama.
/// Implementacija će koristiti Supabase kada baza bude dostupna.
abstract class ReservationRepository {
  /// Kreira novu rezervaciju (status: pending)
  Future<Reservation> createReservation(BookingData bookingData, String userId);

  /// Dohvaća rezervacije trenutnog korisnika
  Future<List<Reservation>> getMyReservations(String userId);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/reservation.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/supabase_reservation_repository.dart';
import '../domain/reservation_repository.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return SupabaseReservationRepository(ref.read(supabaseClientProvider));
});

final myReservationsProvider =
    FutureProvider.family<List<Reservation>, String>((ref, userId) async {
  final repo = ref.read(reservationRepositoryProvider);
  return repo.getMyReservations(userId);
});

final reservedIntervalsProvider = FutureProvider.family<
    List<ReservedInterval>,
    ({DateTime date, String spaceId, String userId})>((ref, params) async {
  final repo = ref.read(reservationRepositoryProvider);
  return repo.getReservedIntervals(
    spaceId: params.spaceId,
    date: params.date,
    userId: params.userId,
  );
});

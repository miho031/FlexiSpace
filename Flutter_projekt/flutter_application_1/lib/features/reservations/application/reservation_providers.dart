import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/reservation.dart';
import '../data/mock_reservation_repository.dart';
import '../domain/reservation_repository.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return MockReservationRepository();
});

final myReservationsProvider = FutureProvider.family<List<Reservation>, String>((ref, userId) async {
  final repo = ref.read(reservationRepositoryProvider);
  return repo.getMyReservations(userId);
});

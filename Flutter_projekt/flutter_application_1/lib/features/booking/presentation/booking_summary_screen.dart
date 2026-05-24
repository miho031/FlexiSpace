import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/booking_data.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_messages.dart';
import '../../profile/application/profile_providers.dart';
import '../../reservations/application/reservation_providers.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final BookingData bookingData;

  const BookingSummaryScreen({super.key, required this.bookingData});

  @override
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bookingData = widget.bookingData;
    final room = bookingData.room;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _RoomSummaryImage(imagePath: room.imagePath),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Adresa: ${room.address}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cijena: ${bookingData.pricePerHour.toStringAsFixed(2).replaceAll('.', ',')} €/h',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Termini: ${bookingData.formattedTimeRanges}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vrijeme trajanja: ${bookingData.formattedDuration}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${bookingData.totalPrice.toStringAsFixed(2).replaceAll('.', ',')} €',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: AppTheme.yellowButton,
                  onPressed: _isLoading ? null : () => _onBooking(bookingData),
                  child: Text(_isLoading ? 'Spremanje...' : 'Rezerviraj'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onBooking(BookingData bookingData) async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) {
      AppSnackBars.showWarning(context, 'Morate biti prijavljeni.');
      return;
    }

    final userId = user.id;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .createProfileIfNotExists(userId, email: user.email);
      await ref
          .read(reservationRepositoryProvider)
          .createReservations(bookingData, userId);
      ref.invalidate(myReservationsProvider(userId));
      ref.invalidate(
        reservedIntervalsProvider((
          spaceId: bookingData.room.id,
          date: bookingData.date,
          userId: userId,
        )),
      );
      if (mounted) {
        AppSnackBars.showSuccess(context, 'Rezervacija je uspjesno kreirana.');
        context.go('/rooms');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.showError(
          context,
          e,
          fallback:
              'Rezervacija nije spremljena. Osvjezite termine i pokusajte ponovno.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _RoomSummaryImage extends StatelessWidget {
  const _RoomSummaryImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.meeting_room,
      size: 56,
      color: Colors.grey.shade600,
    );

    if (imagePath.isEmpty) return fallback;

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

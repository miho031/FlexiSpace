import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/booking_data.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../reservations/application/reservation_providers.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final BookingData bookingData;

  const BookingSummaryScreen({super.key, required this.bookingData});

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
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
                        color: Colors.black.withOpacity(0.08),
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
                        child: Icon(
                          Icons.meeting_room,
                          size: 56,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Adresa: ${room.address}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cijena: ${room.pricePerMinute.toStringAsFixed(2)} €/min',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Vrijeme početka: ${bookingData.formattedStartTime}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vrijeme trajanja: ${bookingData.formattedDuration}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
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
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Morate biti prijavljeni.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(reservationRepositoryProvider).createReservation(
            bookingData,
            userId,
          );
      ref.invalidate(myReservationsProvider(userId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervacija uspješno kreirana!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/rooms');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

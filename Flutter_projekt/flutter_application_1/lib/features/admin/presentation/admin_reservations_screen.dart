import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/reservation.dart';
import '../../../core/theme/app_theme.dart';
import '../application/admin_providers.dart';
import '../data/admin_repository.dart';

class AdminReservationsScreen extends ConsumerWidget {
  const AdminReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(adminReservationsProvider);

    return reservationsAsync.when(
      data: (reservations) {
        final pending = reservations.where((r) => r.status == ReservationStatus.pending).toList();
        final approved = reservations.where((r) => r.status == ReservationStatus.approved).toList();
        final rejected = reservations.where((r) => r.status == ReservationStatus.rejected).toList();

        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                Text(
                  'Nema rezervacija',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: AppTheme.primaryYellow,
                unselectedLabelColor: Colors.black87,
                tabs: [
                  Tab(text: 'Na čekanju (${pending.length})'),
                  Tab(text: 'Odobrene (${approved.length})'),
                  Tab(text: 'Odbijene (${rejected.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ReservationList(
                      reservations: pending,
                      showActions: true,
                      onRefresh: () => ref.invalidate(adminReservationsProvider),
                      parentRef: ref,
                    ),
                    _ReservationList(
                      reservations: approved,
                      showActions: false,
                      onRefresh: () => ref.invalidate(adminReservationsProvider),
                      parentRef: ref,
                    ),
                    _ReservationList(
                      reservations: rejected,
                      showActions: false,
                      onRefresh: () => ref.invalidate(adminReservationsProvider),
                      parentRef: ref,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Greška: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Provjerite je li Supabase baza dostupna.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReservationList extends ConsumerWidget {
  const _ReservationList({
    required this.reservations,
    required this.showActions,
    required this.onRefresh,
    required this.parentRef,
  });

  final List<AdminReservationView> reservations;
  final bool showActions;
  final VoidCallback onRefresh;
  final WidgetRef parentRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(
          'Nema rezervacija',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => parentRef.invalidate(adminReservationsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          return _AdminReservationCard(
            reservation: reservations[index],
            showActions: showActions,
            onApproved: () => _approve(parentRef, context, reservations[index].id, onRefresh),
            onRejected: () => _reject(parentRef, context, reservations[index].id, onRefresh),
          );
        },
      ),
    );
  }

  Future<void> _approve(WidgetRef ref, BuildContext context, String id, VoidCallback onRefresh) async {
    try {
      await ref.read(adminRepositoryProvider).approveReservation(id);
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervacija odobrena'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    }
  }

  Future<void> _reject(WidgetRef ref, BuildContext context, String id, VoidCallback onRefresh) async {
    try {
      await ref.read(adminRepositoryProvider).rejectReservation(id);
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervacija odbijena'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    }
  }
}

class _AdminReservationCard extends StatelessWidget {
  const _AdminReservationCard({
    required this.reservation,
    required this.showActions,
    required this.onApproved,
    required this.onRejected,
  });

  final AdminReservationView reservation;
  final bool showActions;
  final VoidCallback onApproved;
  final VoidCallback onRejected;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(reservation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.spaceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reservation.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${reservation.formattedDate} • ${reservation.formattedTimeRange}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '${reservation.totalPrice.toStringAsFixed(2)} €',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRejected,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Odbij'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApproved,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.green),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    child: const Text('Odobri'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.approved:
        return Colors.green;
      case ReservationStatus.rejected:
        return Colors.red;
    }
  }
}

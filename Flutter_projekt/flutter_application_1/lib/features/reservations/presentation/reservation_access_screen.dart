import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/reservation.dart';
import '../../../core/theme/app_theme.dart';

class ReservationAccessScreen extends StatelessWidget {
  const ReservationAccessScreen({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final hasWifiPassword =
        reservation.room.hasWifi && reservation.room.wifiPassword.isNotEmpty;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.gradientBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Expanded(
                    child: Text(
                      'Pristup prostoriji',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AccessCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      reservation.room.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${reservation.formattedDate} - ${reservation.formattedTimeRange}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _PlaceholderQrCode(seed: reservation.id),
                    const SizedBox(height: 16),
                    const Text(
                      'QR kod za pametnu bravu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (reservation.room.hasWifi) ...[
                const SizedBox(height: 16),
                _AccessCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.wifi,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wi-Fi sifra',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              hasWifiPassword
                                  ? reservation.room.wifiPassword
                                  : 'Sifra jos nije unesena.',
                              style: TextStyle(
                                fontSize: hasWifiPassword ? 18 : 14,
                                fontWeight: hasWifiPassword
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: hasWifiPassword
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ReservationAccessErrorScreen extends StatelessWidget {
  const ReservationAccessErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.gradientBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _AccessCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lock_clock_outlined,
                      color: AppTheme.danger,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kodovi nisu dostupni',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pristupni QR kod i Wi-Fi sifra prikazuju se samo za odobrene rezervacije. Osvjezite rezervacije ili pokusajte ponovno.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/reservations'),
                      child: const Text('Natrag na rezervacije'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _PlaceholderQrCode extends StatelessWidget {
  const _PlaceholderQrCode({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    const cells = 11;
    final hash = seed.hashCode.abs();

    return Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cells,
        ),
        itemCount: cells * cells,
        itemBuilder: (context, index) {
          final row = index ~/ cells;
          final col = index % cells;
          final isFinder =
              _isFinderCell(row, col, 0, 0) ||
              _isFinderCell(row, col, 0, cells - 3) ||
              _isFinderCell(row, col, cells - 3, 0);
          final isFilled = isFinder || ((hash >> ((row + col) % 24)) & 1) == 1;

          return Container(
            margin: const EdgeInsets.all(1.2),
            decoration: BoxDecoration(
              color: isFilled ? AppTheme.primaryBlack : Colors.white,
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        },
      ),
    );
  }

  bool _isFinderCell(int row, int col, int top, int left) {
    final inBox = row >= top && row < top + 3 && col >= left && col < left + 3;
    if (!inBox) return false;
    final localRow = row - top;
    final localCol = col - left;
    return localRow == 0 ||
        localRow == 2 ||
        localCol == 0 ||
        localCol == 2 ||
        (localRow == 1 && localCol == 1);
  }
}

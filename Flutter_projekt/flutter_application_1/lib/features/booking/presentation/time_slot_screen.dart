import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/booking_data.dart';
import '../../../core/models/room.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../reservations/application/reservation_providers.dart';
import '../../reservations/domain/reservation_repository.dart';

class TimeSlotScreen extends ConsumerStatefulWidget {
  final Room room;
  final DateTime date;

  const TimeSlotScreen({super.key, required this.room, required this.date});

  @override
  ConsumerState<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends ConsumerState<TimeSlotScreen> {
  final Set<int> _selectedSlotIndices = {};

  static const List<Map<String, int>> _slots = [
    {'start': 8, 'end': 9},
    {'start': 9, 'end': 10},
    {'start': 10, 'end': 11},
    {'start': 11, 'end': 12},
    {'start': 12, 'end': 13},
    {'start': 13, 'end': 14},
    {'start': 14, 'end': 15},
    {'start': 15, 'end': 16},
    {'start': 16, 'end': 17},
    {'start': 17, 'end': 18},
    {'start': 18, 'end': 19},
    {'start': 19, 'end': 20},
    {'start': 20, 'end': 21},
  ];

  void _toggleSlot(int index, Set<int> blockedIndices) {
    if (blockedIndices.contains(index)) return;

    setState(() {
      if (_selectedSlotIndices.contains(index)) {
        _selectedSlotIndices.remove(index);
      } else {
        _selectedSlotIndices.add(index);
      }
    });
  }

  BookingData? _buildBookingData() {
    if (_selectedSlotIndices.isEmpty) return null;
    final sorted = _selectedSlotIndices.toList()..sort();
    final ranges = <BookingTimeRange>[];
    var rangeStartIndex = sorted.first;
    var previousIndex = sorted.first;

    for (final index in sorted.skip(1)) {
      if (index == previousIndex + 1) {
        previousIndex = index;
        continue;
      }

      ranges.add(_bookingRangeFromSlotIndexes(rangeStartIndex, previousIndex));
      rangeStartIndex = index;
      previousIndex = index;
    }
    ranges.add(_bookingRangeFromSlotIndexes(rangeStartIndex, previousIndex));

    return BookingData(
      room: widget.room,
      date: widget.date,
      timeRanges: ranges,
    );
  }

  BookingTimeRange _bookingRangeFromSlotIndexes(int firstIndex, int lastIndex) {
    final startSlot = _slots[firstIndex];
    return BookingTimeRange(
      startHour: startSlot['start']!,
      durationMinutes: (lastIndex - firstIndex + 1) * 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 400;
    final selectedCount = _selectedSlotIndices.length;
    final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final intervalsAsync = userId == null
        ? const AsyncValue<List<ReservedInterval>>.data(<ReservedInterval>[])
        : ref.watch(
            reservedIntervalsProvider(
              (
                spaceId: widget.room.id,
                date: widget.date,
                userId: userId,
              ),
            ),
          );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              if (selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Odabrano termina: $selectedCount',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: intervalsAsync.when(
                  data: (intervals) {
                    final blockedIndices = _blockedSlotIndices(intervals);
                    _selectedSlotIndices.removeAll(blockedIndices);

                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20),
                      padding: EdgeInsets.all(isNarrow ? 12 : 20),
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
                      child: ListView.builder(
                        itemCount: _slots.length,
                        itemBuilder: (context, index) {
                          final slot = _slots[index];
                          final start = slot['start']!;
                          final end = slot['end']!;
                          final isSelected =
                              _selectedSlotIndices.contains(index);
                          final isBlocked = blockedIndices.contains(index);

                          return InkWell(
                            onTap: isBlocked
                                ? null
                                : () => _toggleSlot(index, blockedIndices),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isBlocked
                                            ? Colors.red.shade700
                                            : isSelected
                                                ? AppTheme.primaryYellow
                                                : Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      color: isBlocked
                                          ? Colors.red.shade100
                                          : isSelected
                                              ? AppTheme.primaryYellow
                                              : Colors.transparent,
                                    ),
                                    child: isBlocked
                                        ? Icon(
                                            Icons.block,
                                            size: 16,
                                            color: Colors.red.shade700,
                                          )
                                        : isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.black,
                                              )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      '${start.toString().padLeft(2, '0')}:00 - ${end.toString().padLeft(2, '0')}:00',
                                      style: TextStyle(
                                        fontSize: isNarrow ? 14 : 16,
                                        color: isBlocked
                                            ? Colors.red.shade800
                                            : Colors.black87,
                                        fontWeight: isBlocked
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isBlocked)
                                    Text(
                                      'Zauzeto',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Greska u ucitavanju termina: $error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isNarrow ? 12 : 20),
                child: ElevatedButton(
                  style: AppTheme.yellowButton,
                  onPressed: _selectedSlotIndices.isEmpty
                      ? null
                      : () {
                          final bookingData = _buildBookingData();
                          if (bookingData != null) {
                            context.push(
                              '/rooms/${widget.room.id}/summary',
                              extra: bookingData,
                            );
                          }
                        },
                  child: Text(
                    _selectedSlotIndices.isEmpty
                        ? 'Odaberi termine'
                        : 'Potvrdi (${_selectedSlotIndices.length} termina)',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Set<int> _blockedSlotIndices(List<ReservedInterval> intervals) {
    final blocked = <int>{};
    for (var index = 0; index < _slots.length; index++) {
      final slot = _slots[index];
      final slotStart = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        slot['start']!,
      );
      final slotEnd = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        slot['end']!,
      );

      if (intervals.any((interval) => interval.overlaps(slotStart, slotEnd))) {
        blocked.add(index);
      }
    }
    return blocked;
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/booking_data.dart';
import '../../../core/models/room.dart';
import '../../../core/theme/app_theme.dart';

class TimeSlotScreen extends StatefulWidget {
  final Room room;
  final DateTime date;

  const TimeSlotScreen({super.key, required this.room, required this.date});

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
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

  void _toggleSlot(int index) {
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
    final firstIndex = sorted.first;
    final lastIndex = sorted.last;
    final startSlot = _slots[firstIndex];
    final durationMinutes = (lastIndex - firstIndex + 1) * 60;
    return BookingData(
      room: widget.room,
      date: widget.date,
      startHour: startSlot['start']!,
      startMinute: 0,
      durationMinutes: durationMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 400;
    final selectedCount = _selectedSlotIndices.length;

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
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20),
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
                      final isSelected = _selectedSlotIndices.contains(index);

                      return InkWell(
                        onTap: () => _toggleSlot(index),
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
                                    color: isSelected
                                        ? AppTheme.primaryYellow
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: isSelected
                                      ? AppTheme.primaryYellow
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${start.toString().padLeft(2, '0')}:00 - ${end.toString().padLeft(2, '0')}:00',
                                style: TextStyle(
                                  fontSize: isNarrow ? 14 : 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/room.dart';
import '../../../core/theme/app_theme.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Odaberi datum',
      cancelText: 'Odustani',
      confirmText: 'Odaberi',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryYellow,
                  onPrimary: Colors.black,
                ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final isNarrow = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isNarrow ? 12 : 20),
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
                  padding: EdgeInsets.all(isNarrow ? 16 : 20),
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
                        style: TextStyle(
                          fontSize: isNarrow ? 18 : 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.meeting_room,
                            size: isNarrow ? 48 : 64,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Adresa: ${room.address}',
                        style: TextStyle(
                          fontSize: isNarrow ? 13 : 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cijena: ${room.pricePerMinute.toStringAsFixed(2)} €/min',
                        style: TextStyle(
                          fontSize: isNarrow ? 13 : 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Odaberi datum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 24,
                                color: AppTheme.primaryYellow,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}.',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: AppTheme.yellowButton,
                  onPressed: () {
                    context.push(
                      '/rooms/${room.id}/time',
                      extra: {'room': room, 'date': _selectedDate},
                    );
                  },
                  child: const Text('Odaberi vrijeme'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

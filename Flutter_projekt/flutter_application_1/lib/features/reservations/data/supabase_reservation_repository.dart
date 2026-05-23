import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/booking_data.dart';
import '../../../core/models/reservation.dart';
import '../../../core/models/room.dart';
import '../domain/reservation_repository.dart';

class SupabaseReservationRepository implements ReservationRepository {
  SupabaseReservationRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<Reservation>> createReservations(
    BookingData bookingData,
    String userId,
  ) async {
    final intervals = await getReservedIntervals(
      spaceId: bookingData.room.id,
      date: bookingData.date,
      userId: userId,
    );

    for (final range in bookingData.timeRanges) {
      final start = _dateTimeForRange(bookingData.date, range);
      final end = start.add(Duration(minutes: range.durationMinutes));
      final hasConflict = intervals.any(
        (interval) => interval.blocksBooking && interval.overlaps(start, end),
      );
      if (hasConflict) {
        throw Exception(
          'Odabrani termin ${range.formattedTimeRange} vise nije dostupan.',
        );
      }
    }

    final rows = bookingData.timeRanges.map((range) {
      final start = _dateTimeForRange(bookingData.date, range);
      final end = start.add(Duration(minutes: range.durationMinutes));
      return {
        'user_id': userId,
        'space_id': bookingData.room.id,
        'start_time': start.toIso8601String(),
        'end_time': end.toIso8601String(),
        'status': 'pending',
      };
    }).toList();

    final res = await _supabase.from('reservations').insert(rows).select('''
          id,
          space_id,
          start_time,
          end_time,
          status,
          spaces:space_id (
            id,
            name,
            address,
            price_per_minute,
            capacity,
            has_wifi,
            has_water,
            is_active,
            image_url
          )
        ''');

    final list = res as List;
    return list
        .map((e) => _reservationFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<Reservation>> getMyReservations(String userId) async {
    final res = await _supabase
        .from('reservations')
        .select('''
          id,
          space_id,
          start_time,
          end_time,
          status,
          spaces:space_id (
            id,
            name,
            address,
            price_per_minute,
            capacity,
            has_wifi,
            has_water,
            is_active,
            image_url
          )
        ''')
        .eq('user_id', userId)
        .order('start_time', ascending: false);

    final list = res as List;
    return list
        .map((e) => _reservationFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<ReservedInterval>> getReservedIntervals({
    required String spaceId,
    required DateTime date,
    required String userId,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final res = await _supabase
        .from('reservations')
        .select('user_id, start_time, end_time, status')
        .eq('space_id', spaceId)
        .lt('start_time', dayEnd.toIso8601String())
        .gt('end_time', dayStart.toIso8601String());

    final list = res as List;
    return list
        .map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          final status = map['status'] as String? ?? 'pending';
          final reservationUserId = map['user_id'] as String? ?? '';
          final isApproved = status == 'approved';
          final isOwnActiveReservation =
              reservationUserId == userId && status != 'rejected';

          return ReservedInterval(
            startTime: DateTime.parse(map['start_time'] as String).toLocal(),
            endTime: DateTime.parse(map['end_time'] as String).toLocal(),
            blocksBooking: isApproved || isOwnActiveReservation,
          );
        })
        .where((interval) => interval.blocksBooking)
        .toList();
  }

  Reservation _reservationFromMap(Map<String, dynamic> map) {
    final room = _roomFromMap(
      Map<String, dynamic>.from(map['spaces'] as Map),
      map['space_id'] as String,
    );
    final start = DateTime.parse(map['start_time'] as String).toLocal();
    final end = DateTime.parse(map['end_time'] as String).toLocal();

    return Reservation(
      id: map['id'] as String,
      room: room,
      startTime: start,
      endTime: end,
      status: _parseStatus(map['status'] as String?),
      totalPrice: room.pricePerMinute * end.difference(start).inMinutes,
    );
  }

  Room _roomFromMap(Map<String, dynamic> map, String fallbackId) {
    return Room(
      id: map['id'] as String? ?? fallbackId,
      name: map['name'] as String? ?? 'Nepoznata prostorija',
      imagePath: _resolveSpaceImageUrl(map['image_url'] as String?),
      address: map['address'] as String? ?? '',
      pricePerMinute: (map['price_per_minute'] as num?)?.toDouble() ?? 0,
      capacity: map['capacity'] as int? ?? 1,
      hasWifi: map['has_wifi'] as bool? ?? false,
      hasWater: map['has_water'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  ReservationStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
        return ReservationStatus.approved;
      case 'rejected':
        return ReservationStatus.rejected;
      default:
        return ReservationStatus.pending;
    }
  }

  DateTime _dateTimeForRange(DateTime date, BookingTimeRange range) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      range.startHour,
      range.startMinute,
    );
  }

  String _resolveSpaceImageUrl(String? value) {
    final imagePath = value?.trim() ?? '';
    if (imagePath.isEmpty) return '';

    final uri = Uri.tryParse(imagePath);
    if (uri != null && uri.hasScheme && uri.hasAuthority) {
      return imagePath;
    }

    var objectPath = imagePath.replaceAll('\\', '/');
    while (objectPath.startsWith('/')) {
      objectPath = objectPath.substring(1);
    }

    const bucketName = 'spaces';
    if (objectPath.startsWith('$bucketName/')) {
      objectPath = objectPath.substring(bucketName.length + 1);
    }

    if (objectPath.isEmpty) return '';
    return _supabase.storage.from(bucketName).getPublicUrl(objectPath);
  }
}

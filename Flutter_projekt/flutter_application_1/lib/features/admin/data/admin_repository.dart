import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/reservation.dart';
import '../../../core/models/room.dart';

/// Repository za admin operacije - koristi Supabase.
class AdminRepository {
  AdminRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Dohvaća sve rezervacije s podacima o prostoriji.
  Future<List<AdminReservationView>> getAllReservations() async {
    final res = await _supabase
        .from('reservations')
        .select('''
          id,
          user_id,
          space_id,
          start_time,
          end_time,
          status,
          spaces:space_id (id, name, address, price_per_minute)
        ''')
        .order('start_time', ascending: false);

    final list = res as List;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final spacesData = map['spaces'];
      final spaceName = spacesData != null
          ? (spacesData as Map<String, dynamic>)['name'] as String?
          : null;
      final pricePerMin = spacesData != null
          ? (spacesData as Map<String, dynamic>)['price_per_minute'] != null
              ? (spacesData['price_per_minute'] as num).toDouble()
              : 0.0
          : 0.0;
      final start = DateTime.parse(map['start_time'] as String);
      final end = DateTime.parse(map['end_time'] as String);
      final durationMin = end.difference(start).inMinutes;
      return AdminReservationView(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        spaceId: map['space_id'] as String,
        spaceName: spaceName ?? 'Nepoznata prostorija',
        startTime: start,
        endTime: end,
        status: _parseStatus(map['status'] as String?),
        totalPrice: pricePerMin * durationMin,
      );
    }).toList();
  }

  ReservationStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved':
        return ReservationStatus.approved;
      case 'rejected':
        return ReservationStatus.rejected;
      default:
        return ReservationStatus.pending;
    }
  }

  /// Odobrava rezervaciju.
  Future<void> approveReservation(String reservationId) async {
    await _supabase
        .from('reservations')
        .update({'status': 'approved', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', reservationId);
  }

  /// Odbija rezervaciju.
  Future<void> rejectReservation(String reservationId) async {
    await _supabase
        .from('reservations')
        .update({'status': 'rejected', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', reservationId);
  }

  /// Dohvaća sve prostorije (uključujući neaktivne).
  Future<List<Room>> getAllSpaces() async {
    final res = await _supabase.from('spaces').select().order('name');
    final list = res as List;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Room(
        id: map['id'] as String,
        name: map['name'] as String,
        imagePath: map['image_url'] as String? ?? '',
        address: map['address'] as String? ?? '',
        pricePerMinute: (map['price_per_minute'] as num?)?.toDouble() ?? 0,
        capacity: map['capacity'] as int? ?? 1,
        hasWifi: map['has_wifi'] as bool? ?? false,
        hasWater: map['has_water'] as bool? ?? false,
        isActive: map['is_active'] as bool? ?? true,
      );
    }).toList();
  }

  /// Kreira novu prostoriju.
  Future<Room> createSpace({
    required String name,
    required String address,
    required double pricePerMinute,
    required int capacity,
    bool hasWifi = false,
    bool hasWater = false,
    String? imageUrl,
    String type = 'meeting_room',
  }) async {
    final res = await _supabase.from('spaces').insert({
      'name': name,
      'address': address,
      'price_per_minute': pricePerMinute,
      'capacity': capacity,
      'has_wifi': hasWifi,
      'has_water': hasWater,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      'type': type,
    }).select().single();

    final map = Map<String, dynamic>.from(res as Map);
    return Room(
      id: map['id'] as String,
      name: map['name'] as String,
      imagePath: map['image_url'] as String? ?? '',
      address: map['address'] as String? ?? '',
      pricePerMinute: (map['price_per_minute'] as num?)?.toDouble() ?? 0,
      capacity: map['capacity'] as int? ?? 1,
      hasWifi: map['has_wifi'] as bool? ?? false,
      hasWater: map['has_water'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  /// Ažurira prostoriju.
  Future<void> updateSpace(
    String spaceId, {
    String? name,
    String? address,
    double? pricePerMinute,
    int? capacity,
    bool? hasWifi,
    bool? hasWater,
    bool? isActive,
    String? imageUrl,
    String? type,
  }) async {
    final updates = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (name != null) updates['name'] = name;
    if (address != null) updates['address'] = address;
    if (pricePerMinute != null) updates['price_per_minute'] = pricePerMinute;
    if (capacity != null) updates['capacity'] = capacity;
    if (hasWifi != null) updates['has_wifi'] = hasWifi;
    if (hasWater != null) updates['has_water'] = hasWater;
    if (isActive != null) updates['is_active'] = isActive;
    if (imageUrl != null) updates['image_url'] = imageUrl.isEmpty ? null : imageUrl;
    if (type != null) updates['type'] = type;

    await _supabase.from('spaces').update(updates).eq('id', spaceId);
  }

  /// Briše prostoriju (ili deaktivira).
  Future<void> deleteSpace(String spaceId) async {
    await _supabase.from('spaces').update({
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', spaceId);
  }
}

/// Pogled rezervacije za admin panel.
class AdminReservationView {
  final String id;
  final String userId;
  final String spaceId;
  final String spaceName;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final double totalPrice;

  AdminReservationView({
    required this.id,
    required this.userId,
    required this.spaceId,
    required this.spaceName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
  });

  String get formattedDate =>
      '${startTime.day.toString().padLeft(2, '0')}.${startTime.month.toString().padLeft(2, '0')}.${startTime.year}';

  String get formattedTimeRange =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - '
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  String get statusLabel {
    switch (status) {
      case ReservationStatus.pending:
        return 'Na čekanju';
      case ReservationStatus.approved:
        return 'Odobreno';
      case ReservationStatus.rejected:
        return 'Odbijeno';
    }
  }
}

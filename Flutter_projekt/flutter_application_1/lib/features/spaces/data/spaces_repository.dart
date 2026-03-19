import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/room.dart';

/// Repository za dohvat prostorija (samo aktivne, za korisnike).
class SpacesRepository {
  SpacesRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Dohvaća sve aktivne prostorije.
  Future<List<Room>> getActiveSpaces() async {
    final res = await _supabase
        .from('spaces')
        .select()
        .eq('is_active', true)
        .order('name');

    final list = res as List;
    return list.map((e) => _roomFromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  Room _roomFromMap(Map<String, dynamic> map) {
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
}

import '../../../core/data/rooms_data.dart';
import '../../../core/models/room.dart';
import '../domain/space_repository.dart';

/// Mock implementacija - koristi hardcoded podatke dok Supabase nije dostupan.
class MockSpaceRepository implements SpaceRepository {
  @override
  Future<List<Room>> getSpaces() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return roomsData;
  }
}

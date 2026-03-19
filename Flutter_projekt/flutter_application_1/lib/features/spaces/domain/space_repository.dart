import '../../../core/models/room.dart';

/// Sučelje za pristup prostorijama.
/// Implementacija će koristiti Supabase kada baza bude dostupna.
abstract class SpaceRepository {
  Future<List<Room>> getSpaces();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/room.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/spaces_repository.dart';

final spacesRepositoryProvider = Provider<SpacesRepository>((ref) {
  return SpacesRepository(ref.read(supabaseClientProvider));
});

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return ref.read(spacesRepositoryProvider).getActiveSpaces();
});

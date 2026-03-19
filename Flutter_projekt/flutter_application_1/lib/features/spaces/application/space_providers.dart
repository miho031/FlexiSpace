import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/room.dart';
import '../data/mock_space_repository.dart';
import '../domain/space_repository.dart';

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  return MockSpaceRepository();
});

final spacesProvider = FutureProvider<List<Room>>((ref) async {
  final repo = ref.read(spaceRepositoryProvider);
  return repo.getSpaces();
});

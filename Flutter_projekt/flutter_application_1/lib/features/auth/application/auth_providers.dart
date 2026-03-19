import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../data/auth_repository.dart';
import '../data/supabase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabase);
});

Stream<Session?> _authSessionStream(SupabaseClient supabase) async* {
  // Emitujemo početnu sesiju pa onda kontinuirano slušamo promjene auth state-a.
  yield supabase.auth.currentSession;
  yield* supabase.auth.onAuthStateChange.map((event) => event.session);
}

/// Riverpod "auth state listener" koji emitira `Session?` pri promjenama.
final authSessionStreamProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return _authSessionStream(supabase);
});

/// Stream samo promjena (bez inicijalnog emitovanja) - pogodan za go_router refresh.
final authStateChangesStreamProvider = Provider<Stream<Session?>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session);
});


import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user?.id;
  }

  @override
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return res.user?.id;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}


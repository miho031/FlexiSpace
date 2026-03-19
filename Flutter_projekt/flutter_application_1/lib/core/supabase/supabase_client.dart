import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Centralni Supabase client kojeg koristi cijeli app.
/// Koristi Supabase.instance nakon inicijalizacije u main().
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (Supabase.instance.isInitialized) return Supabase.instance.client;

  final (url, anonKey) = getSupabaseConfig();
  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError(
      'Missing Supabase config. Edit .env file with your SUPABASE_URL and SUPABASE_ANON_KEY '
      '(from Supabase Dashboard → Project Settings → API).',
    );
  }
  if (url.contains('REPLACE') || anonKey.contains('REPLACE')) {
    throw StateError(
      'Replace placeholder values in .env with your real Supabase credentials.',
    );
  }
  return SupabaseClient(url, anonKey);
});


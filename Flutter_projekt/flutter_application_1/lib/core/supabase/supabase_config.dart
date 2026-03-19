import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Učitava Supabase URL i anon key iz .env ili --dart-define.
/// Koristi se za inicijalizaciju prije runApp.
(String url, String anonKey) getSupabaseConfig() {
  var url = const String.fromEnvironment('SUPABASE_URL', defaultValue: '').trim();
  var anonKey =
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '').trim();

  if (url.isEmpty || anonKey.isEmpty) {
    url = dotenv.env['SUPABASE_URL'] ?? '';
    anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  return (url, anonKey);
}

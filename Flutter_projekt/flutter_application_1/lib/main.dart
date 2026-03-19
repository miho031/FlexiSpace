import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env nije pronađen – koristit će se --dart-define ako je proslijeđen
  }
  final (url, anonKey) = getSupabaseConfig();
  if (url.isNotEmpty && anonKey.isNotEmpty && !url.contains('REPLACE')) {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
  runApp(const ProviderScope(child: FlexiSpaceApp()));
}

class FlexiSpaceApp extends ConsumerWidget {
  const FlexiSpaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    ref.watch(authSessionStreamProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FlexiSpace',
      theme: ThemeData(
        fontFamily: 'Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryYellow,
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}

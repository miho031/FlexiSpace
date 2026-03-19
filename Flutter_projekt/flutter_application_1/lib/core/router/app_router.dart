import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_reservations_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/admin_space_form_screen.dart';
import '../../features/admin/presentation/admin_spaces_screen.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/booking/presentation/booking_summary_screen.dart';
import '../../features/booking/presentation/room_detail_screen.dart';
import '../../features/booking/presentation/time_slot_screen.dart';
import '../../features/profile/application/profile_providers.dart';
import '../../features/reservations/presentation/my_reservations_screen.dart';
import '../../rezervacije_screen.dart';
import '../widgets/main_shell.dart';
import '../models/booking_data.dart';
import '../models/room.dart';
import '../supabase/supabase_client.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Stream stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangesStream = ref.read(authStateChangesStreamProvider);
  final refreshNotifier = _RouterRefreshNotifier(authChangesStream);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final session = ref.read(supabaseClientProvider).auth.currentSession;
      final isLoggedIn = session != null;

      final loc = state.matchedLocation;
      final isLoginRoute = loc == '/login';
      final isRegisterRoute = loc == '/register';
      final isRoomsRoute = loc.startsWith('/rooms');
      final isReservationsRoute = loc == '/reservations';
      final isAdminRoute = loc.startsWith('/admin');

      if (!isLoggedIn) {
        if (isLoginRoute || isRegisterRoute) return null;
        return '/login';
      }

      if (isLoginRoute || isRegisterRoute) return '/rooms';

      if (isAdminRoute) {
        final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (userId == null) return '/rooms';
        final profile = await ref.read(profileRepositoryProvider).getProfile(userId);
        if (profile?.role != 'admin') return '/rooms';
      }

      if (isRoomsRoute || isReservationsRoute || isAdminRoute) return null;

      return '/rooms';
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) =>
            state.uri.path == '/' ? '/rooms' : null,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: 'rooms',
                builder: (context, state) => const RoomsPage(),
                routes: [
                  GoRoute(
                    path: ':roomId',
                    builder: (context, state) {
                      final room = state.extra as Room?;
                      if (room == null) return const SizedBox.shrink();
                      return RoomDetailScreen(room: room);
                    },
                    routes: [
                      GoRoute(
                        path: 'time',
                        builder: (context, state) {
                          final data = state.extra as Map<String, dynamic>?;
                          if (data == null) return const SizedBox.shrink();
                          final room = data['room'] as Room;
                          final date = data['date'] as DateTime;
                          return TimeSlotScreen(room: room, date: date);
                        },
                      ),
                      GoRoute(
                        path: 'summary',
                        builder: (context, state) {
                          final bookingData = state.extra as BookingData?;
                          if (bookingData == null) return const SizedBox.shrink();
                          return BookingSummaryScreen(bookingData: bookingData);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'reservations',
                builder: (context, state) => const MyReservationsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) =>
            state.uri.path == '/admin' ? '/admin/reservations' : null,
        routes: [
          ShellRoute(
            builder: (context, state, child) => AdminShell(child: child),
            routes: [
              GoRoute(
                path: 'reservations',
                builder: (context, state) => const AdminReservationsScreen(),
              ),
              GoRoute(
                path: 'spaces',
                builder: (context, state) => const AdminSpacesScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const AdminSpaceFormScreen(),
                  ),
                  GoRoute(
                    path: ':spaceId/edit',
                    builder: (context, state) {
                      final room = state.extra as Room?;
                      if (room == null) return const SizedBox.shrink();
                      return AdminSpaceFormScreen(room: room);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'users',
                builder: (context, state) => const AdminUsersScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

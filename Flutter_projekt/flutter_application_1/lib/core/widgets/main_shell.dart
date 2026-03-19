import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/profile/application/profile_providers.dart';

/// Shell s drawer navigacijom za glavne ekrane (Rezerviraj, Moje rezervacije).
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      drawer: _MainDrawer(currentPath: currentPath),
      body: child,
    );
  }
}

class _MainDrawer extends ConsumerWidget {
  const _MainDrawer({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.cardWhite,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'FlexiSpace',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.meeting_room,
              label: 'Rezerviraj',
              path: '/rooms',
              currentPath: currentPath,
              onTap: () {
                Navigator.pop(context);
                context.go('/rooms');
              },
            ),
            _DrawerItem(
              icon: Icons.event_note,
              label: 'Moje rezervacije',
              path: '/reservations',
              currentPath: currentPath,
              onTap: () {
                Navigator.pop(context);
                context.go('/reservations');
              },
            ),
            _AdminDrawerItem(currentPath: currentPath),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Odjava'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawerItem extends ConsumerWidget {
  const _AdminDrawerItem({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) return const SizedBox.shrink();
        return _DrawerItem(
          icon: Icons.admin_panel_settings,
          label: 'Admin',
          path: '/admin',
          currentPath: currentPath,
          onTap: () {
            Navigator.pop(context);
            context.go('/admin/reservations');
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String path;
  final String currentPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPath == path || currentPath.startsWith('$path/');

    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryYellow : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppTheme.primaryYellow : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Shell za admin panel s tab navigacijom.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppTheme.gradientStart,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/rooms'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.cardWhite,
            child: Row(
              children: [
                _buildTab(context, 'Rezervacije', '/admin/reservations', path),
                _buildTab(context, 'Prostorije', '/admin/spaces', path),
                _buildTab(context, 'Korisnici', '/admin/users', path),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: child,
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, String route, String currentPath) {
    final isSelected = currentPath == route || currentPath.startsWith('$route/');
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryYellow : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

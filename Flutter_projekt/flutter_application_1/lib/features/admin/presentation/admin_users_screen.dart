import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile.dart';
import '../../../core/theme/app_theme.dart';
import '../application/admin_providers.dart';
import '../../profile/application/profile_providers.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(adminProfilesProvider);

    return profilesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) {
          return Center(
            child: Text(
              'Nema korisnika',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminProfilesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              return _UserCard(
                profile: profiles[index],
                onRoleChanged: (role) => _updateRole(ref, context, profiles[index].id, role),
                onMembershipToggled: () =>
                    _toggleMembership(ref, context, profiles[index]),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('Greška: $err', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateRole(WidgetRef ref, BuildContext context, String userId, String role) async {
    try {
      await ref.read(profileRepositoryProvider).updateProfile(userId, role: role);
      ref.invalidate(adminProfilesProvider);
      ref.invalidate(currentProfileProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uloga ažurirana')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    }
  }

  Future<void> _toggleMembership(WidgetRef ref, BuildContext context, Profile profile) async {
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            profile.id,
            membershipActive: !profile.membershipActive,
          );
      ref.invalidate(adminProfilesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profile.membershipActive ? 'Članstvo deaktivirano' : 'Članstvo aktivirano',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.profile,
    required this.onRoleChanged,
    required this.onMembershipToggled,
  });

  final Profile profile;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onMembershipToggled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.fullName ?? 'Bez imena',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (profile.role == 'admin' ? Colors.blue : Colors.grey)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.role == 'admin' ? 'Admin' : 'Član',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: profile.role == 'admin' ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (profile.email != null) ...[
            const SizedBox(height: 4),
            Text(
              profile.email!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Uloga: ', style: TextStyle(fontSize: 14)),
              DropdownButton<String>(
                value: profile.role,
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('Član')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) {
                  if (v != null && v != profile.role) onRoleChanged(v);
                },
              ),
              const Spacer(),
              Text(
                profile.membershipActive ? 'Aktivan' : 'Neaktivan',
                style: TextStyle(
                  fontSize: 14,
                  color: profile.membershipActive ? Colors.green : Colors.red,
                ),
              ),
              TextButton(
                onPressed: onMembershipToggled,
                child: Text(profile.membershipActive ? 'Deaktiviraj' : 'Aktiviraj'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

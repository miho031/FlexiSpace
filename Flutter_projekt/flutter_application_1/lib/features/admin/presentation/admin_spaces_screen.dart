import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/room.dart';
import '../../../core/theme/app_theme.dart';
import '../../spaces/application/spaces_providers.dart';
import '../application/admin_providers.dart';

class AdminSpacesScreen extends ConsumerWidget {
  const AdminSpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(adminSpacesProvider);

    return spacesAsync.when(
      data: (spaces) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showAddSpace(context),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj prostoriju'),
                style: AppTheme.yellowButton,
              ),
            ),
            Expanded(
              child: spaces.isEmpty
                  ? Center(
                      child: Text(
                        'Nema prostorija',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(adminSpacesProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: spaces.length,
                        itemBuilder: (context, index) {
                          return _SpaceCard(
                            room: spaces[index],
                            onEdit: () => _showEditSpace(context, spaces[index]),
                            onToggleActive: () =>
                                _toggleSpaceActive(ref, context, spaces[index]),
                          );
                        },
                      ),
                    ),
            ),
          ],
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

  void _showAddSpace(BuildContext context) {
    context.push('/admin/spaces/new');
  }

  void _showEditSpace(BuildContext context, Room room) {
    context.push('/admin/spaces/${room.id}/edit', extra: room);
  }

  Future<void> _toggleSpaceActive(WidgetRef ref, BuildContext context, Room room) async {
    try {
      await ref.read(adminRepositoryProvider).updateSpace(
            room.id,
            isActive: !room.isActive,
          );
      ref.invalidate(adminSpacesProvider);
      ref.invalidate(roomsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(room.isActive ? 'Prostorija deaktivirana' : 'Prostorija aktivirana'),
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

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.room,
    required this.onEdit,
    required this.onToggleActive,
  });

  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

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
                  room.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Adresa: ${room.address}', style: const TextStyle(fontSize: 14)),
          Text('Cijena: ${room.pricePerMinute} €/min', style: const TextStyle(fontSize: 14)),
          Text('Kapacitet: ${room.capacity}', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (room.hasWifi) const Icon(Icons.wifi, size: 18),
              if (room.hasWater) const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.videocam, size: 18),
              ),
              const Spacer(),
              TextButton(
                onPressed: onToggleActive,
                child: Text(room.isActive ? 'Deaktiviraj' : 'Aktiviraj'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/models/room.dart';
import 'core/theme/app_theme.dart';
import 'features/spaces/application/spaces_providers.dart';

class RoomsPage extends ConsumerWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    return roomsAsync.when(
      data: (rooms) => _RoomsContent(rooms: rooms),
      loading: () => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.black54),
              const SizedBox(height: 16),
              Text(
                'Greška u učitavanju prostorija',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomsContent extends ConsumerWidget {
  final List<Room> rooms;

  const _RoomsContent({required this.rooms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu, color: Colors.black),
                    ),
                    const Expanded(
                      child: Text(
                        'Rezerviraj',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on, color: Colors.black),
                    ),
                  ],
                ),
              ),
              // Lista prostorija
              Expanded(
                child: rooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Nema dostupnih prostorija',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          return _RoomCard(
                            room: rooms[index],
                            onTap: () {
                              context.push('/rooms/${rooms[index].id}', extra: rooms[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _RoomThumbnail(imagePath: room.imagePath),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (room.hasWifi)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.wifi, size: 18, color: Colors.black54),
                        ),
                      if (room.hasWater)
                        const Icon(Icons.videocam, size: 18, color: Colors.black54),
                      const Spacer(),
                      const Icon(Icons.groups, size: 18, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${room.capacity}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomThumbnail extends StatelessWidget {
  final String imagePath;

  const _RoomThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: imagePath.isEmpty
          ? Icon(Icons.meeting_room, color: Colors.grey.shade600, size: 32)
          : imagePath.startsWith('http')
              ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.meeting_room, color: Colors.grey.shade600, size: 32))
              : Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.meeting_room, color: Colors.grey.shade600, size: 32)),
    );
  }
}

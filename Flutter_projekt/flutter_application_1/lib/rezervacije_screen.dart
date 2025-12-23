import 'package:flutter/material.dart';

class Room {
  final String name;
  final String imagePath;
  final int capacity;
  final bool hasWifi;
  final bool hasProjector;

  Room({
    required this.name,
    required this.imagePath,
    required this.capacity,
    required this.hasWifi,
    required this.hasProjector,
  });
}

class RoomsPage extends StatelessWidget {
  RoomsPage({super.key});

  final List<Room> rooms = [
    Room(
      name: 'Orlando sala',
      imagePath: '../assets/orlando.jpg',
      capacity: 30,
      hasWifi: true,
      hasProjector: true,
    ),
    Room(
      name: 'Učionica 3C',
      imagePath: 'assets/3c.jpg',
      capacity: 24,
      hasWifi: false,
      hasProjector: false,
    ),
    Room(
      name: 'Study corner',
      imagePath: 'assets/study.jpg',
      capacity: 16,
      hasWifi: true,
      hasProjector: false,
    ),
    Room(
      name: 'Library room',
      imagePath: 'assets/library.jpg',
      capacity: 4,
      hasWifi: false,
      hasProjector: false,
    ),
    Room(
      name: 'Collab zone',
      imagePath: 'assets/collab.jpg',
      capacity: 10,
      hasWifi: true,
      hasProjector: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9C8C44),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6D36F),
        elevation: 2,
        title: const Text('Rezerviraj', style: TextStyle(color: Colors.black)),
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: const [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.location_on, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return RoomCard(
            room: rooms[index],
            onTap: () {
              // 👉 OVDJE KASNIJE IDE NAVIGACIJA
              // Navigator.push(...)
            },
          );
        },
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0D8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                room.imagePath,
                width: 90,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (room.hasWifi) const Icon(Icons.wifi, size: 18),
                      if (room.hasProjector)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.tv, size: 18),
                        ),
                      const Spacer(),
                      const Icon(Icons.people, size: 18),
                      const SizedBox(width: 4),
                      Text('${room.capacity}'),
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

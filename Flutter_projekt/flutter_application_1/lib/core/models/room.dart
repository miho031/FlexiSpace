/// Model prostorije za rezervaciju
class Room {
  final String id;
  final String name;
  final String imagePath;
  final String address;
  final double pricePerMinute;
  final int capacity;
  final bool hasWifi;
  final bool hasWater;
  final bool isActive;

  Room({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.address,
    required this.pricePerMinute,
    required this.capacity,
    this.hasWifi = false,
    this.hasWater = false,
    this.isActive = true,
  });
}

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
  final String wifiPassword;

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
    this.wifiPassword = '',
  });

  double get pricePerHour => pricePerMinute * 60;
}

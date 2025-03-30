// lib/domain/entities/location.dart
class Location {
  final String locationName;
  final Coordinates coordinates;

  Location({
    required this.locationName,
    required this.coordinates,
  });
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });
}

// lib/data/models/location_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/location.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final String locationName;
  final CoordinatesModel coordinates;

  LocationModel({
    required this.locationName,
    required this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  Location toEntity() => Location(
        locationName: locationName,
        coordinates: coordinates.toEntity(),
      );

  static LocationModel fromEntity(Location location) => LocationModel(
        locationName: location.locationName,
        coordinates: CoordinatesModel.fromEntity(location.coordinates),
      );
}

@JsonSerializable()
class CoordinatesModel {
  final double latitude;
  final double longitude;

  CoordinatesModel({
    required this.latitude,
    required this.longitude,
  });

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesModelFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinatesModelToJson(this);

  Coordinates toEntity() => Coordinates(
        latitude: latitude,
        longitude: longitude,
      );

  static CoordinatesModel fromEntity(Coordinates coordinates) =>
      CoordinatesModel(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
}

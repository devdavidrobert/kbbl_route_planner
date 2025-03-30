// lib/domain/entities/customer.dart
import 'distributor.dart';
import 'location.dart';

class Customer {
  final String id;
  final String name;
  final List<Distributor> distributors;
  final Location location;
  final String userId;
  final String? region;
  final String? territory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.distributors,
    required this.location,
    required this.userId,
    this.region,
    this.territory,
    required this.createdAt,
    required this.updatedAt,
  });
}

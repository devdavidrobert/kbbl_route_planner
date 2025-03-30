// lib/domain/entities/customer.dart
import 'distributor.dart';
import 'location.dart';

class Customer {
  final String id;
  final String name;
  final List<Distributor> distributors;
  final String invoiceName;
  final Location location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.distributors,
    required this.invoiceName,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
}

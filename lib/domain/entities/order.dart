// lib/domain/entities/order.dart
class Order {
  final String id;
  final String customerId;
  final String userId;
  final Map<String, Map<String, int>> skus; // e.g., {'Original': {'300ml': 5}}
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.skus,
    required this.createdAt,
    required this.updatedAt,
  });
}

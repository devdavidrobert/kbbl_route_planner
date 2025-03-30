// lib/domain/entities/stock.dart
class Stock {
  final String id;
  final String customerId;
  final String userId;
  final String status; // 'stocking', 'out_of_stock', 'never_stocked'
  final DateTime createdAt;
  final DateTime updatedAt;

  Stock({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

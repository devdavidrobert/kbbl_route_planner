// lib/domain/entities/sales.dart
class Sales {
  final String orderId;
  final String userId;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime date;

  Sales({
    required this.orderId,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.date,
  });
}

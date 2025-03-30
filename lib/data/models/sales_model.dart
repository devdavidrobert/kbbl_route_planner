// lib/data/models/sales_model.dart
class SalesModel {
  final String orderId;
  final String userId;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime date;

  SalesModel({
    required this.orderId,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.date,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

// lib/data/models/order_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  final String customerId;
  @JsonKey(name: 'userId')
  final String userId;  // This will be mapped to MongoDB ObjectId
  @JsonKey(fromJson: _skusFromJson, toJson: _skusToJson)
  final Map<String, Map<String, int>> skus;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.skus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  Order toEntity() => Order(
        id: id,
        customerId: customerId,
        userId: userId,
        skus: skus,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static OrderModel fromEntity(Order order) => OrderModel(
        id: order.id,
        customerId: order.customerId,
        userId: order.userId,
        skus: order.skus,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );

  static Map<String, Map<String, int>> _skusFromJson(Map<String, dynamic> json) {
    return json.map((key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as int),
          ),
        ));
  }

  static Map<String, dynamic> _skusToJson(Map<String, Map<String, int>> skus) {
    return skus.map((key, value) => MapEntry(
          key,
          value.map((k, v) => MapEntry(k, v)),
        ));
  }
}

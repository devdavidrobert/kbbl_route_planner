// lib/data/models/stock_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stock.dart';

part 'stock_model.g.dart';

@JsonSerializable()
class StockModel {
  final String id;
  final String customerId;
  final String userId;
  final String status; // 'stocking', 'out_of_stock', 'never_stocked'
  final DateTime createdAt;
  final DateTime updatedAt;

  StockModel({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);
  Map<String, dynamic> toJson() => _$StockModelToJson(this);

  Stock toEntity() => Stock(
        id: id,
        customerId: customerId,
        userId: userId,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static StockModel fromEntity(Stock stock) => StockModel(
        id: stock.id,
        customerId: stock.customerId,
        userId: stock.userId,
        status: stock.status,
        createdAt: stock.createdAt,
        updatedAt: stock.updatedAt,
      );
}

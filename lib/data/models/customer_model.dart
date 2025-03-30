// lib/data/models/customer_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer.dart';
import 'distributor_model.dart';
import 'location_model.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  final String id;
  final String name;
  final List<DistributorModel> distributors;
  final String invoiceName;
  final LocationModel location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.distributors,
    required this.invoiceName,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  Customer toEntity() => Customer(
        id: id,
        name: name,
        distributors: distributors.map((d) => d.toEntity()).toList(),
        invoiceName: invoiceName,
        location: location.toEntity(),
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static CustomerModel fromEntity(Customer customer) => CustomerModel(
        id: customer.id,
        name: customer.name,
        distributors: customer.distributors
            .map((d) => DistributorModel.fromEntity(d))
            .toList(),
        invoiceName: customer.invoiceName,
        location: LocationModel.fromEntity(customer.location),
        userId: customer.userId,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
      );
}

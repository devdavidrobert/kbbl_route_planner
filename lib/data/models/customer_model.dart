// lib/data/models/customer_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer.dart';
import 'distributor_model.dart';
import 'location_model.dart';

part 'customer_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomerModel {
  final String id;
  final String name;
  final List<DistributorModel> distributors;
  final LocationModel location;
  @JsonKey(name: 'userId')
  final String userId;  // This will be mapped to MongoDB ObjectId on the backend
  final String? region;
  final String? territory;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
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

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  Customer toEntity() => Customer(
        id: id,
        name: name,
        distributors: distributors.map((d) => d.toEntity()).toList(),
        location: location.toEntity(),
        userId: userId,
        region: region,
        territory: territory,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static CustomerModel fromEntity(Customer customer) => CustomerModel(
        id: customer.id,
        name: customer.name,
        distributors: customer.distributors
            .map((d) => DistributorModel.fromEntity(d))
            .toList(),
        location: LocationModel.fromEntity(customer.location),
        userId: customer.userId,
        region: customer.region,
        territory: customer.territory,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
      );
}

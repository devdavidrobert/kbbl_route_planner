// lib/data/models/distributor_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/distributor.dart';

part 'distributor_model.g.dart';

@JsonSerializable()
class DistributorModel {
  final String id;
  final String name;
  final String contactInfo;

  DistributorModel({
    required this.id,
    required this.name,
    required this.contactInfo,
  });

  factory DistributorModel.fromJson(Map<String, dynamic> json) =>
      _$DistributorModelFromJson(json);
  Map<String, dynamic> toJson() => _$DistributorModelToJson(this);

  Distributor toEntity() => Distributor(
        id: id,
        name: name,
        contactInfo: contactInfo,
      );

  static DistributorModel fromEntity(Distributor distributor) =>
      DistributorModel(
        id: distributor.id,
        name: distributor.name,
        contactInfo: distributor.contactInfo,
      );
}

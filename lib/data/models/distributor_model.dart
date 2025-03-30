// lib/data/models/distributor_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/distributor.dart';

part 'distributor_model.g.dart';

@JsonSerializable()
class DistributorModel {
  final String id;
  final String name;
  final String invoiceName;

  DistributorModel({
    required this.id,
    required this.name,
    required this.invoiceName,
  });

  factory DistributorModel.fromJson(Map<String, dynamic> json) =>
      _$DistributorModelFromJson(json);
  Map<String, dynamic> toJson() => _$DistributorModelToJson(this);

  Distributor toEntity() => Distributor(
        id: id,
        name: name,
        invoiceName: invoiceName,
      );

  static DistributorModel fromEntity(Distributor distributor) =>
      DistributorModel(
        id: distributor.id,
        name: distributor.name,
        invoiceName: distributor.invoiceName,
      );
}

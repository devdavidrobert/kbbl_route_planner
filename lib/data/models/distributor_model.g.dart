// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distributor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DistributorModel _$DistributorModelFromJson(Map<String, dynamic> json) =>
    DistributorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactInfo: json['contactInfo'] as String,
    );

Map<String, dynamic> _$DistributorModelToJson(DistributorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contactInfo': instance.contactInfo,
    };

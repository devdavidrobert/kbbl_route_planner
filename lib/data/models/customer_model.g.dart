// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      distributors: (json['distributors'] as List<dynamic>)
          .map((e) => DistributorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      invoiceName: json['invoiceName'] as String,
      location:
          LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'distributors': instance.distributors,
      'invoiceName': instance.invoiceName,
      'location': instance.location,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

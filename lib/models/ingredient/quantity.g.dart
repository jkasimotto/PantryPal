// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quantity _$QuantityFromJson(Map<String, dynamic> json) => Quantity(
      amount: (json['amount'] as num).toDouble(),
      units: json['units'] as String,
    );

Map<String, dynamic> _$QuantityToJson(Quantity instance) => <String, dynamic>{
      'amount': instance.amount,
      'units': instance.units,
    };

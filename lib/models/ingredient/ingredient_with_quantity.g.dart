// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_with_quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientWithQuantity _$IngredientWithQuantityFromJson(
        Map<String, dynamic> json) =>
    IngredientWithQuantity(
      ingredientData: IngredientData.fromJson(
          json['ingredientData'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      units: json['units'] as String,
    );

Map<String, dynamic> _$IngredientWithQuantityToJson(
        IngredientWithQuantity instance) =>
    <String, dynamic>{
      'ingredientData': instance.ingredientData.toJson(),
      'quantity': instance.quantity,
      'units': instance.units,
    };

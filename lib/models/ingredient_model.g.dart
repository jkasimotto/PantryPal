// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuantityData _$QuantityDataFromJson(Map<String, dynamic> json) => QuantityData(
      value: (json['value'] as num).toDouble(),
      units: json['units'] as String?,
    );

Map<String, dynamic> _$QuantityDataToJson(QuantityData instance) =>
    <String, dynamic>{
      'value': instance.value,
      'units': instance.units,
    };

NutritionalInformation _$NutritionalInformationFromJson(
        Map<String, dynamic> json) =>
    NutritionalInformation(
      calories: (json['calories'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      vitamins: (json['vitamins'] as num).toDouble(),
      minerals: (json['minerals'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionalInformationToJson(
        NutritionalInformation instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'fats': instance.fats,
      'carbohydrates': instance.carbohydrates,
      'proteins': instance.proteins,
      'vitamins': instance.vitamins,
      'minerals': instance.minerals,
    };

IngredientData _$IngredientDataFromJson(Map<String, dynamic> json) =>
    IngredientData(
      name: json['name'] as String,
      quantity: QuantityData.fromJson(json['quantity'] as Map<String, dynamic>),
      form: json['form'] as String,
      category: json['category'] as String,
      allergens: (json['allergens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      substitutions: (json['substitutions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nutritionalInformation: NutritionalInformation.fromJson(
          json['nutritionalInformation'] as Map<String, dynamic>),
      shelfLife: json['shelfLife'] as String,
      seasonality: json['seasonality'] as String?,
    );

Map<String, dynamic> _$IngredientDataToJson(IngredientData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity.toJson(),
      'form': instance.form,
      'category': instance.category,
      'allergens': instance.allergens,
      'substitutions': instance.substitutions,
      'nutritionalInformation': instance.nutritionalInformation.toJson(),
      'shelfLife': instance.shelfLife,
      'seasonality': instance.seasonality,
    };

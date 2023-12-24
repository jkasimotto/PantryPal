// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientData _$IngredientDataFromJson(Map<String, dynamic> json) =>
    IngredientData(
      name: json['name'] as String,
      form: json['form'] as String?,
      category: json['category'] as String,
      shelfLife: json['shelfLife'] as String,
      nutritionalInformation: json['nutritionalInformation'] == null
          ? null
          : NutritionalInformation.fromJson(
              json['nutritionalInformation'] as Map<String, dynamic>),
      seasonality: json['seasonality'] as String?,
      allergens: (json['allergens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      substitutions: (json['substitutions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      iconPath:
          json['iconPath'] as String? ?? 'assets/images/icons/food/default.png',
    );

Map<String, dynamic> _$IngredientDataToJson(IngredientData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'form': instance.form,
      'category': instance.category,
      'shelfLife': instance.shelfLife,
      'nutritionalInformation': instance.nutritionalInformation?.toJson(),
      'seasonality': instance.seasonality,
      'allergens': instance.allergens,
      'substitutions': instance.substitutions,
      'iconPath': instance.iconPath,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
      name: json['name'] as String,
      meta: IngredientMeta.fromJson(json['meta'] as Map<String, dynamic>),
      form: json['form'] as String?,
      category: json['category'] as String?,
      shelfLife: json['shelfLife'] as String?,
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
    );

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'form': instance.form,
      'category': instance.category,
      'shelfLife': instance.shelfLife,
      'nutritionalInformation': instance.nutritionalInformation?.toJson(),
      'seasonality': instance.seasonality,
      'allergens': instance.allergens,
      'substitutions': instance.substitutions,
      'meta': instance.meta.toJson(),
    };

IngredientWithQuantity _$IngredientWithQuantityFromJson(
        Map<String, dynamic> json) =>
    IngredientWithQuantity(
      name: json['name'] as String,
      meta: IngredientMeta.fromJson(json['meta'] as Map<String, dynamic>),
      quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
      form: json['form'] as String?,
      category: json['category'] as String?,
      shelfLife: json['shelfLife'] as String?,
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
    );

Map<String, dynamic> _$IngredientWithQuantityToJson(
        IngredientWithQuantity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'form': instance.form,
      'category': instance.category,
      'shelfLife': instance.shelfLife,
      'nutritionalInformation': instance.nutritionalInformation?.toJson(),
      'seasonality': instance.seasonality,
      'allergens': instance.allergens,
      'substitutions': instance.substitutions,
      'meta': instance.meta.toJson(),
      'quantity': instance.quantity.toJson(),
    };

IngredientMeta _$IngredientMetaFromJson(Map<String, dynamic> json) =>
    IngredientMeta(
      iconPath:
          json['iconPath'] as String? ?? 'assets/images/icons/food/default.png',
      ingredientId: json['ingredientId'] as String?,
    );

Map<String, dynamic> _$IngredientMetaToJson(IngredientMeta instance) =>
    <String, dynamic>{
      'iconPath': instance.iconPath,
      'ingredientId': instance.ingredientId,
    };

ShoppingListIngredient _$ShoppingListIngredientFromJson(
        Map<String, dynamic> json) =>
    ShoppingListIngredient(
      name: json['name'] as String,
      meta: IngredientMeta.fromJson(json['meta'] as Map<String, dynamic>),
      quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
      location: $enumDecode(_$ShoppingLocationEnumMap, json['location']),
      form: json['form'] as String?,
      category: json['category'] as String?,
      shelfLife: json['shelfLife'] as String?,
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
    );

Map<String, dynamic> _$ShoppingListIngredientToJson(
        ShoppingListIngredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'form': instance.form,
      'category': instance.category,
      'shelfLife': instance.shelfLife,
      'nutritionalInformation': instance.nutritionalInformation?.toJson(),
      'seasonality': instance.seasonality,
      'allergens': instance.allergens,
      'substitutions': instance.substitutions,
      'meta': instance.meta.toJson(),
      'quantity': instance.quantity.toJson(),
      'location': _$ShoppingLocationEnumMap[instance.location]!,
    };

const _$ShoppingLocationEnumMap = {
  ShoppingLocation.Produce: 'Produce',
  ShoppingLocation.Meat_Seafood: 'Meat & Seafood',
  ShoppingLocation.Dairy: 'Dairy',
  ShoppingLocation.Frozen_Foods: 'Frozen Foods',
  ShoppingLocation.Aisle: 'Aisle',
};

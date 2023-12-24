// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingListIngredientData _$ShoppingListIngredientDataFromJson(
        Map<String, dynamic> json) =>
    ShoppingListIngredientData(
      ingredientName: json['ingredientName'] as String,
      ingredientForm: json['ingredientForm'] as String,
      ingredientCategory: json['ingredientCategory'] as String,
      iconPath:
          json['iconPath'] as String? ?? 'assets/images/icons/food/default.png',
      quantity: (json['quantity'] as num).toDouble(),
      units: json['units'] as String,
      location: $enumDecode(_$ShoppingLocationEnumMap, json['location']),
    );

Map<String, dynamic> _$ShoppingListIngredientDataToJson(
        ShoppingListIngredientData instance) =>
    <String, dynamic>{
      'ingredientName': instance.ingredientName,
      'ingredientForm': instance.ingredientForm,
      'ingredientCategory': instance.ingredientCategory,
      'iconPath': instance.iconPath,
      'quantity': instance.quantity,
      'units': instance.units,
      'location': _$ShoppingLocationEnumMap[instance.location]!,
    };

const _$ShoppingLocationEnumMap = {
  ShoppingLocation.Produce: 'Produce',
  ShoppingLocation.Meat_Seafood: 'Meat_Seafood',
  ShoppingLocation.Dairy: 'Dairy',
  ShoppingLocation.Frozen_Foods: 'Frozen_Foods',
  ShoppingLocation.Aisle: 'Aisle',
};

ShoppingListData _$ShoppingListDataFromJson(Map<String, dynamic> json) =>
    ShoppingListData(
      recipeTitles: (json['recipeTitles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) =>
              ShoppingListIngredientData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShoppingListDataToJson(ShoppingListData instance) =>
    <String, dynamic>{
      'recipeTitles': instance.recipeTitles,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
    };

ShoppingListMetadata _$ShoppingListMetadataFromJson(
        Map<String, dynamic> json) =>
    ShoppingListMetadata(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      status: $enumDecode(_$StatusEnumMap, json['status']),
    );

Map<String, dynamic> _$ShoppingListMetadataToJson(
        ShoppingListMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'status': _$StatusEnumMap[instance.status]!,
    };

const _$StatusEnumMap = {
  Status.loading: 'loading',
  Status.success: 'success',
  Status.error: 'error',
};

ShoppingListModel _$ShoppingListModelFromJson(Map<String, dynamic> json) =>
    ShoppingListModel(
      data: ShoppingListData.fromJson(json['data'] as Map<String, dynamic>),
      metadata: ShoppingListMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShoppingListModelToJson(ShoppingListModel instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'metadata': instance.metadata.toJson(),
    };

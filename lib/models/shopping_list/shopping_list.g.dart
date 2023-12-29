// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
      recipeTitles: (json['recipeTitles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map(
              (e) => ShoppingListIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: ShoppingListMetadata.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShoppingListToJson(ShoppingList instance) =>
    <String, dynamic>{
      'recipeTitles': instance.recipeTitles,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map(
              (e) => IngredientWithQuantity.fromJson(e as Map<String, dynamic>))
          .toList(),
      method: (json['method'] as List<dynamic>)
          .map((e) => RecipeMethodStepData.fromJson(e as Map<String, dynamic>))
          .toList(),
      cuisine: json['cuisine'] as String,
      course: json['course'] as String,
      servings: json['servings'] as int,
      prepTime: json['prepTime'] as int,
      cookTime: json['cookTime'] as int,
      notes: json['notes'] as String?,
      meta: RecipeMetadata.fromJson(json['meta'] as Map<String, dynamic>),
      firebaseImagePaths: (json['firebaseImagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'method': instance.method.map((e) => e.toJson()).toList(),
      'cuisine': instance.cuisine,
      'course': instance.course,
      'servings': instance.servings,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'notes': instance.notes,
      'meta': instance.meta.toJson(),
      'firebaseImagePaths': instance.firebaseImagePaths,
    };

RecipeMetadata _$RecipeMetadataFromJson(Map<String, dynamic> json) =>
    RecipeMetadata(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      source: $enumDecode(_$RecipeSourceEnumMap, json['source']),
      status: $enumDecode(_$StatusEnumMap, json['status']),
    );

Map<String, dynamic> _$RecipeMetadataToJson(RecipeMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'source': _$RecipeSourceEnumMap[instance.source]!,
      'status': _$StatusEnumMap[instance.status]!,
    };

const _$RecipeSourceEnumMap = {
  RecipeSource.text: 'text',
  RecipeSource.youtube: 'youtube',
  RecipeSource.webpage: 'webpage',
  RecipeSource.image: 'image',
  RecipeSource.video: 'video',
};

const _$StatusEnumMap = {
  Status.loading: 'loading',
  Status.success: 'success',
  Status.error: 'error',
};

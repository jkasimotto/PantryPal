// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeData _$RecipeDataFromJson(Map<String, dynamic> json) => RecipeData(
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => IngredientData.fromJson(e as Map<String, dynamic>))
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
    );

Map<String, dynamic> _$RecipeDataToJson(RecipeData instance) =>
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
    };

RecipeMetadata _$RecipeMetadataFromJson(Map<String, dynamic> json) =>
    RecipeMetadata(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      source: $enumDecode(_$SourceEnumMap, json['source']),
      status: $enumDecode(_$StatusEnumMap, json['status']),
    );

Map<String, dynamic> _$RecipeMetadataToJson(RecipeMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'source': _$SourceEnumMap[instance.source]!,
      'status': _$StatusEnumMap[instance.status]!,
    };

const _$SourceEnumMap = {
  Source.text: 'text',
  Source.youtube: 'youtube',
  Source.webpage: 'webpage',
  Source.image: 'image',
  Source.video: 'video',
};

const _$StatusEnumMap = {
  Status.loading: 'loading',
  Status.success: 'success',
  Status.error: 'error',
};

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
      data: RecipeData.fromJson(json['data'] as Map<String, dynamic>),
      metadata:
          RecipeMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'metadata': instance.metadata.toJson(),
    };

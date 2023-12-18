// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_method_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeMethodStepData _$RecipeMethodStepDataFromJson(
        Map<String, dynamic> json) =>
    RecipeMethodStepData(
      stepNumber: json['stepNumber'] as int,
      description: json['description'] as String,
      duration: json['duration'] as int?,
      additionalNotes: json['additionalNotes'] as String?,
    );

Map<String, dynamic> _$RecipeMethodStepDataToJson(
        RecipeMethodStepData instance) =>
    <String, dynamic>{
      'stepNumber': instance.stepNumber,
      'description': instance.description,
      'duration': instance.duration,
      'additionalNotes': instance.additionalNotes,
    };

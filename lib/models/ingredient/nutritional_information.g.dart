// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutritional_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

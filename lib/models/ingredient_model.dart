import 'package:json_annotation/json_annotation.dart';

part 'ingredient_model.g.dart';

@JsonSerializable()
class QuantityData {
  final double value;
  final String? units;

  QuantityData({required this.value, required this.units});

  factory QuantityData.fromJson(Map<String, dynamic> json) =>
      _$QuantityDataFromJson(json);
  Map<String, dynamic> toJson() => _$QuantityDataToJson(this);
}

@JsonSerializable()
class NutritionalInformation {
  final double calories;
  final double fats;
  final double carbohydrates;
  final double proteins;
  final double vitamins;
  final double minerals;

  NutritionalInformation(
      {required this.calories,
      required this.fats,
      required this.carbohydrates,
      required this.proteins,
      required this.vitamins,
      required this.minerals});

  factory NutritionalInformation.fromJson(Map<String, dynamic> json) =>
      _$NutritionalInformationFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionalInformationToJson(this);
}

@JsonSerializable()
class IngredientData {
  final String name;
  final QuantityData quantity;
  final String form;
  final String category;
  final List<String>? allergens;
  final List<String>? substitutions;
  final NutritionalInformation nutritionalInformation;
  final String shelfLife;
  final String? seasonality;

  IngredientData(
      {required this.name,
      required this.quantity,
      required this.form,
      required this.category,
      this.allergens,
      this.substitutions,
      required this.nutritionalInformation,
      required this.shelfLife,
      this.seasonality});

  factory IngredientData.fromJson(Map<String, dynamic> json) => _$IngredientDataFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientDataToJson(this);
}

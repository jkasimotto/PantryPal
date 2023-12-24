import 'package:flutter_recipes/models/ingredient/nutritional_information.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_data.g.dart';

@JsonSerializable(explicitToJson: true)
class IngredientData {
  final String name;
  final String? form;
  final String category;
  final String shelfLife;
  final NutritionalInformation? nutritionalInformation;
  final String? seasonality;
  final List<String>? allergens;
  final List<String>? substitutions;
  final String iconPath;

  IngredientData(
      {required this.name,
      this.form,
      required this.category,
      required this.shelfLife,
      this.nutritionalInformation,
      this.seasonality,
      this.allergens,
      this.substitutions,
      this.iconPath = 'assets/images/icons/food/default.png'});

  factory IngredientData.fromJson(Map<String, dynamic> json) =>
      _$IngredientDataFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientDataToJson(this);
}

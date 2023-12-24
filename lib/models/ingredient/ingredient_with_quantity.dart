import 'package:flutter_recipes/models/ingredient/ingredient_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_with_quantity.g.dart';

@JsonSerializable(explicitToJson: true)
class IngredientWithQuantity {
  final IngredientData ingredientData;
  final double quantity; // Quantity quantity
  final String units; // Quantity units

  IngredientWithQuantity({
    required this.ingredientData,
    required this.quantity, // Initialize quantity quantity
    required this.units, // Initialize quantity units
  });

  // Add fromJson and toJson methods
  factory IngredientWithQuantity.fromJson(Map<String, dynamic> json) =>
      _$IngredientWithQuantityFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientWithQuantityToJson(this);
}

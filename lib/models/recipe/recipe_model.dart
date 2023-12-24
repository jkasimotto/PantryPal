import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_data.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_with_quantity.dart';
import 'package:flutter_recipes/models/ingredient/nutritional_information.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/recipe/source.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeData {
  final String title;
  final List<IngredientWithQuantity> ingredients;
  final List<RecipeMethodStepData> method;
  final String cuisine;
  final String course;
  final int servings;
  final int prepTime;
  final int cookTime;
  final String? notes;

  RecipeData({
    required this.title,
    required this.ingredients,
    required this.method,
    required this.cuisine,
    required this.course,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    this.notes,
  });

  int get totalTime => prepTime + cookTime;

  // Getter for adjusted ingredients
  List<IngredientWithQuantity> adjustedIngredients(int newServings) {
    return ingredients.map((ingredient) {
      double adjustedValue = (ingredient.quantity * newServings) / servings;
      NutritionalInformation? originalNutrition =
          ingredient.ingredientData.nutritionalInformation;

      NutritionalInformation adjustedNutrition = NutritionalInformation(
        calories: (originalNutrition?.calories ?? 0) * newServings / servings,
        fats: (originalNutrition?.fats ?? 0) * newServings / servings,
        carbohydrates:
            (originalNutrition?.carbohydrates ?? 0) * newServings / servings,
        proteins: (originalNutrition?.proteins ?? 0) * newServings / servings,
        vitamins: (originalNutrition?.vitamins ?? 0) * newServings / servings,
        minerals: (originalNutrition?.minerals ?? 0) * newServings / servings,
      );

      IngredientData newIngredient = IngredientData(
        name: ingredient.ingredientData.name,
        form: ingredient.ingredientData.form,
        category: ingredient.ingredientData.category,
        shelfLife: ingredient.ingredientData.shelfLife,
        nutritionalInformation: adjustedNutrition,
        seasonality: ingredient.ingredientData.seasonality,
        allergens: ingredient.ingredientData.allergens,
        substitutions: ingredient.ingredientData.substitutions,
      );

      return IngredientWithQuantity(
        ingredientData: newIngredient,
        quantity: adjustedValue,
        units: ingredient.units,
      );
    }).toList();
  }

  factory RecipeData.fromJson(Map<String, dynamic> json) =>
      _$RecipeDataFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeMetadata {
  final String id;
  final String ownerId;
  final Source source;
  Status status;

  RecipeMetadata(
      {this.id = '',
      this.ownerId = '',
      required this.source,
      required this.status});

  factory RecipeMetadata.fromJson(Map<String, dynamic> json) =>
      _$RecipeMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeMetadataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeModel extends BaseModel {
  final RecipeData data;

  final RecipeMetadata metadata;

  RecipeModel({
    required this.data,
    required this.metadata,
  });

  @override
  String get id => metadata.id;

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}

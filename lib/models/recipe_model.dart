import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/recipe_method_step_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'ingredient_model.dart'; // Import IngredientData

part 'recipe_model.g.dart';

enum Source {
  text,
  youtube,
  webpage,
  image,
  video,
}

enum Status {
  loading,
  success,
  error
}

enum Difficulty {
  easy,
  medium,
  hard,
}

@JsonSerializable()
class RecipeData {
  final String title;
  final List<IngredientData> ingredients;
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
List<IngredientData> adjustedIngredients(int newServings) {
  return ingredients.map((ingredient) {
    double adjustedValue = (ingredient.quantity.value * newServings) / servings;
    NutritionalInformation adjustedNutrition = NutritionalInformation(
      calories: (ingredient.nutritionalInformation.calories * newServings) / servings,
      fats: (ingredient.nutritionalInformation.fats * newServings) / servings,
      carbohydrates: (ingredient.nutritionalInformation.carbohydrates * newServings) / servings,
      proteins: (ingredient.nutritionalInformation.proteins * newServings) / servings,
      vitamins: (ingredient.nutritionalInformation.vitamins * newServings) / servings,
      minerals: (ingredient.nutritionalInformation.minerals * newServings) / servings,
    );
    return IngredientData(
      name: ingredient.name,
      quantity: QuantityData(value: adjustedValue, units: ingredient.quantity.units),
      form: ingredient.form,
      category: ingredient.category,
      allergens: ingredient.allergens,
      substitutions: ingredient.substitutions,
      nutritionalInformation: adjustedNutrition,
      shelfLife: ingredient.shelfLife,
      seasonality: ingredient.seasonality,
    );
  }).toList();
}

  factory RecipeData.fromJson(Map<String, dynamic> json) => _$RecipeDataFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeDataToJson(this);
}

@JsonSerializable()
class RecipeMetadata {
  final String id;
  final String ownerId;
  final Source source;
  Status status;

  RecipeMetadata({
    this.id = '',
    this.ownerId = '',
    required this.source,
    required this.status 
  });

  factory RecipeMetadata.fromJson(Map<String, dynamic> json) => _$RecipeMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeMetadataToJson(this);
}

@JsonSerializable()
class RecipeModel extends BaseModel {
  final RecipeData data;
  final RecipeMetadata metadata;

  RecipeModel({
    required this.data,
    required this.metadata,
  });

  @override
  String get id => metadata.id;

  factory RecipeModel.fromJson(Map<String, dynamic> json) => _$RecipeModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}
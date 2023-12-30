import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/ingredient/nutritional_information.dart';
import 'package:flutter_recipes/models/ingredient/quantity.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeModel extends BaseModel {
  final String title;
  final List<IngredientWithQuantity> ingredients;
  final List<RecipeMethodStepData> method;
  final String cuisine;
  final String course;
  final int servings;
  final int prepTime;
  final int cookTime;
  final String? notes;
  final RecipeMetadata meta;

  RecipeModel(
      {required this.title,
      required this.ingredients,
      required this.method,
      required this.cuisine,
      required this.course,
      required this.servings,
      required this.prepTime,
      required this.cookTime,
      this.notes,
      required this.meta});

  @override
  String get id => meta.id;

  int get totalTime => prepTime + cookTime;

  RecipeModel copyWith({
    String? title,
    List<IngredientWithQuantity>? ingredients,
    List<RecipeMethodStepData>? method,
    String? cuisine,
    String? course,
    int? servings,
    int? prepTime,
    int? cookTime,
    String? notes,
    RecipeMetadata? meta,
  }) {
    return RecipeModel(
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      method: method ?? this.method,
      cuisine: cuisine ?? this.cuisine,
      course: course ?? this.course,
      servings: servings ?? this.servings,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      notes: notes ?? this.notes,
      meta: meta ?? this.meta,
    );
  }

  // Method to add a new ingredient
  RecipeModel addIngredient(IngredientWithQuantity newIngredient) {
    List<IngredientWithQuantity> updatedIngredients = List.from(ingredients);
    updatedIngredients.add(newIngredient);
    return copyWith(ingredients: updatedIngredients);
  }

  // Method to remove an ingredient
  RecipeModel removeIngredient(String ingredientIdToRemove) {
    List<IngredientWithQuantity> updatedIngredients =
        ingredients.where((ingredient) {
      return ingredient.meta.ingredientId != ingredientIdToRemove;
    }).toList();
    return copyWith(ingredients: updatedIngredients);
  }

  // Method to edit an existing ingredient
  RecipeModel editIngredient(IngredientWithQuantity editedIngredient) {
    List<IngredientWithQuantity> updatedIngredients =
        ingredients.map((ingredient) {
      if (ingredient.meta.ingredientId == editedIngredient.meta.ingredientId) {
        return editedIngredient;
      } else {
        return ingredient;
      }
    }).toList();
    return copyWith(ingredients: updatedIngredients);
  }

  // Getter for adjusted ingredients
  List<IngredientWithQuantity> adjustedIngredients(int newServings) {
    return ingredients.map((ingredient) {
      double adjustedValue =
          (ingredient.quantity.amount * newServings) / servings;
      NutritionalInformation? originalNutrition =
          ingredient.nutritionalInformation;

      NutritionalInformation adjustedNutrition = NutritionalInformation(
        calories: (originalNutrition?.calories ?? 0) * newServings / servings,
        fats: (originalNutrition?.fats ?? 0) * newServings / servings,
        carbohydrates:
            (originalNutrition?.carbohydrates ?? 0) * newServings / servings,
        proteins: (originalNutrition?.proteins ?? 0) * newServings / servings,
        vitamins: (originalNutrition?.vitamins ?? 0) * newServings / servings,
        minerals: (originalNutrition?.minerals ?? 0) * newServings / servings,
      );

      IngredientWithQuantity newIngredient = IngredientWithQuantity(
        name: ingredient.name,
        meta: ingredient.meta,
        form: ingredient.form,
        category: ingredient.category,
        shelfLife: ingredient.shelfLife,
        nutritionalInformation: adjustedNutrition,
        seasonality: ingredient.seasonality,
        allergens: ingredient.allergens,
        substitutions: ingredient.substitutions,
        quantity:
            Quantity(amount: adjustedValue, units: ingredient.quantity.units),
      );

      return newIngredient;
    }).toList();
  }

  RecipeModel generateNewRecipeFromMeta(RecipeMetadata newMeta) {
    return RecipeModel(
        title: title,
        ingredients: ingredients,
        method: method,
        cuisine: cuisine,
        course: course,
        servings: servings,
        prepTime: prepTime,
        cookTime: cookTime,
        notes: notes,
        meta: newMeta);
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeMetadata {
  final String id;
  final String ownerId;
  final RecipeSource source;
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

@JsonEnum(alwaysCreate: true)
enum RecipeSource {
  @JsonValue('text')
  text,
  @JsonValue('youtube')
  youtube,
  @JsonValue('webpage')
  webpage,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
}

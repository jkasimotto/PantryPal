import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/ingredient/nutritional_information.dart';
import 'package:flutter_recipes/models/ingredient/quantity.dart';
import 'package:flutter_recipes/models/shopping_list/location_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_model.g.dart';

// ==================================================================

@JsonSerializable(explicitToJson: true)
class Ingredient extends BaseModel {
  final String name;
  final String? form;
  final String? category;
  final String? shelfLife;
  final NutritionalInformation? nutritionalInformation;
  final String? seasonality;
  final List<String>? allergens;
  final List<String>? substitutions;
  final IngredientMeta meta;

  Ingredient(
      {required this.name,
      required this.meta,
      this.form,
      this.category,
      this.shelfLife,
      this.nutritionalInformation,
      this.seasonality,
      this.allergens,
      this.substitutions});

  @override
  String get id => meta.ingredientId ?? '';

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}

// ==================================================================

@JsonSerializable(explicitToJson: true)
class IngredientWithQuantity extends Ingredient {
  final Quantity quantity;

  IngredientWithQuantity({
    required String name,
    required IngredientMeta meta,
    required this.quantity,
    String? form,
    String? category,
    String? shelfLife,
    NutritionalInformation? nutritionalInformation,
    String? seasonality,
    List<String>? allergens,
    List<String>? substitutions,
  }) : super(
          name: name,
          meta: meta,
          form: form,
          category: category,
          shelfLife: shelfLife,
          nutritionalInformation: nutritionalInformation,
          seasonality: seasonality,
          allergens: allergens,
          substitutions: substitutions,
        );

  IngredientWithQuantity copyWith({
    String? name,
    IngredientMeta? meta,
    Quantity? quantity,
    String? form,
    String? category,
    String? shelfLife,
    NutritionalInformation? nutritionalInformation,
    String? seasonality,
    List<String>? allergens,
    List<String>? substitutions,
    String? iconPath, // Assuming you have this field in your IngredientMeta
  }) {
    return IngredientWithQuantity(
      name: name ?? this.name,
      meta:
          meta ?? this.meta.copyWith(iconPath: iconPath ?? this.meta.iconPath),
      quantity: quantity ?? this.quantity,
      form: form ?? this.form,
      category: category ?? this.category,
      shelfLife: shelfLife ?? this.shelfLife,
      nutritionalInformation:
          nutritionalInformation ?? this.nutritionalInformation,
      seasonality: seasonality ?? this.seasonality,
      allergens: allergens ?? this.allergens,
      substitutions: substitutions ?? this.substitutions,
    );
  }

  factory IngredientWithQuantity.fromJson(Map<String, dynamic> json) =>
      _$IngredientWithQuantityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IngredientWithQuantityToJson(this);
}

// ==================================================================

@JsonSerializable(explicitToJson: true)
class IngredientMeta {
  final String iconPath;
  final String? ingredientId;

  IngredientMeta(
      {this.iconPath = 'assets/images/icons/food/default.png',
      this.ingredientId});

  IngredientMeta copyWith({
    String? iconPath,
    String? ingredientId,
  }) {
    return IngredientMeta(
      iconPath: iconPath ?? this.iconPath,
      ingredientId: ingredientId ?? this.ingredientId,
    );
  }

  factory IngredientMeta.fromJson(Map<String, dynamic> json) =>
      _$IngredientMetaFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientMetaToJson(this);
}
// ==================================================================

@JsonSerializable(explicitToJson: true)
class ShoppingListIngredient extends IngredientWithQuantity {
  final ShoppingLocation location;

  ShoppingListIngredient({
    required String name,
    required IngredientMeta meta,
    required Quantity quantity,
    required this.location,
    String? form,
    String? category,
    String? shelfLife,
    NutritionalInformation? nutritionalInformation,
    String? seasonality,
    List<String>? allergens,
    List<String>? substitutions,
  }) : super(
            name: name,
            meta: meta,
            form: form,
            category: category,
            shelfLife: shelfLife,
            nutritionalInformation: nutritionalInformation,
            seasonality: seasonality,
            allergens: allergens,
            substitutions: substitutions,
            quantity: quantity);

  factory ShoppingListIngredient.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListIngredientFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ShoppingListIngredientToJson(this);
}

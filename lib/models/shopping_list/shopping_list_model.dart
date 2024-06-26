import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shopping_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingList extends BaseModel {
  final List<String> recipeTitles;
  final List<ShoppingListIngredient> ingredients;
  final ShoppingListMetadata meta;

  ShoppingList(
      {required this.recipeTitles,
      required this.ingredients,
      required this.meta});

  @override
  String get id => meta.id;

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);

  static ShoppingList empty() {
    return ShoppingList(
      recipeTitles: [],
      ingredients: [],
      meta: ShoppingListMetadata(
        id: '',
        ownerId: '',
        status: Status.success,
      ),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShoppingListMetadata {
  final String id;
  final String ownerId;
  Status status;

  ShoppingListMetadata({this.id = '', this.ownerId = '', required this.status});

  factory ShoppingListMetadata.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListMetadataToJson(this);
}

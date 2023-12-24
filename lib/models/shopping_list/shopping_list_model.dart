import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/shopping_list/location_data.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shopping_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingListIngredientData {
  final String ingredientName;
  final String ingredientForm;
  final String ingredientCategory;
  final String iconPath;
  final double quantity;
  final String units;
  final ShoppingLocation location;

  ShoppingListIngredientData({
    required this.ingredientName,
    required this.ingredientForm,
    required this.ingredientCategory,
    this.iconPath = 'assets/images/icons/food/default.png',
    required this.quantity,
    required this.units,
    required this.location,
  });

  factory ShoppingListIngredientData.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListIngredientDataFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListIngredientDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ShoppingListData {
  final List<String> recipeTitles;
  final List<ShoppingListIngredientData> ingredients;

  ShoppingListData({required this.recipeTitles, required this.ingredients});

  factory ShoppingListData.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListDataFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListDataToJson(this);
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

@JsonSerializable(explicitToJson: true)
class ShoppingListModel extends BaseModel {
  final ShoppingListData data;
  final ShoppingListMetadata metadata;

  ShoppingListModel({
    required this.data,
    required this.metadata,
  });

  @override
  String get id => metadata.id;

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ShoppingListModelToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'recipe_method_step_model.g.dart';

@JsonSerializable()
class RecipeMethodStepData {
  final int stepNumber;
  final String description;
  final int? duration;
  final String? additionalNotes;

  RecipeMethodStepData({
    required this.stepNumber,
    required this.description,
    this.duration,
    this.additionalNotes,
  });

  factory RecipeMethodStepData.fromJson(Map<String, dynamic> json) => _$RecipeMethodStepDataFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeMethodStepDataToJson(this);
}
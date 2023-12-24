import 'package:json_annotation/json_annotation.dart';

part 'nutritional_information.g.dart';

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

import 'package:json_annotation/json_annotation.dart';

part 'quantity.g.dart';

@JsonSerializable()
class Quantity {
  final double amount;
  final String units;

  Quantity({
    required this.amount,
    required this.units,
  });

  factory Quantity.fromJson(Map<String, dynamic> json) =>
      _$QuantityFromJson(json);
  Map<String, dynamic> toJson() => _$QuantityToJson(this);
}

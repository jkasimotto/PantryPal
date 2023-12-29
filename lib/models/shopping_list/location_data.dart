// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum ShoppingLocation {
  @JsonValue('Produce')
  Produce,
  @JsonValue('Meat & Seafood')
  Meat_Seafood,
  @JsonValue('Dairy')
  Dairy,
  @JsonValue('Frozen Foods')
  Frozen_Foods,
  @JsonValue('Aisle')
  Aisle,
}

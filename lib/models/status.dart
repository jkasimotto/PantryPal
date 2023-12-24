import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum Status {
  @JsonValue('loading')
  loading,
  @JsonValue('success')
  success,
  @JsonValue('error')
  error,
}

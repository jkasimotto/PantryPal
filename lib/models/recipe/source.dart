import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum Source {
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

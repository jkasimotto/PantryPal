import 'package:flutter_recipes/models/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserData {
  final String name;
  final String email;
  String subscriptionPlan;

  UserData({
    required this.name,
    required this.email,
    required this.subscriptionPlan,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class UserMetadata {
  final String id;
  final int signInCount;
  DateTime? lastActive;
  Map<String, int> recipeGenerationCount;
  
  // Add new fields here
  bool hasCompletedHomeScreenTutorial;
  bool hasCompletedTextAction;
  bool hasCompletedYoutubeAction;
  bool hasCompletedCameraAction;
  bool hasCompletedWebAction;

  UserMetadata({
    required this.id,
    required this.signInCount,
    this.lastActive,
    required this.recipeGenerationCount,
    // Initialize new fields here
    this.hasCompletedHomeScreenTutorial = false,
    this.hasCompletedTextAction = false,
    this.hasCompletedYoutubeAction = false,
    this.hasCompletedCameraAction = false,
    this.hasCompletedWebAction = false,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) => _$UserMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$UserMetadataToJson(this);
}

@JsonSerializable()
class UserModel extends BaseModel {
  final UserData data;
  final UserMetadata metadata;

  UserModel({
    required this.data,
    required this.metadata,
  });

  @override
  String get id => metadata.id;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      data: UserData.fromJson(json['data']),
      metadata: UserMetadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}
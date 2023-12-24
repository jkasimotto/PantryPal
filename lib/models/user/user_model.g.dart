// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      name: json['name'] as String,
      email: json['email'] as String,
      subscriptionPlan: json['subscriptionPlan'] as String,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'subscriptionPlan': instance.subscriptionPlan,
    };

UserMetadata _$UserMetadataFromJson(Map<String, dynamic> json) => UserMetadata(
      id: json['id'] as String,
      signInCount: json['signInCount'] as int,
      lastActive: json['lastActive'] == null
          ? null
          : DateTime.parse(json['lastActive'] as String),
      recipeGenerationCount:
          Map<String, int>.from(json['recipeGenerationCount'] as Map),
      hasCompletedHomeScreenTutorial:
          json['hasCompletedHomeScreenTutorial'] as bool? ?? false,
      hasCompletedTextAction: json['hasCompletedTextAction'] as bool? ?? false,
      hasCompletedYoutubeAction:
          json['hasCompletedYoutubeAction'] as bool? ?? false,
      hasCompletedCameraAction:
          json['hasCompletedCameraAction'] as bool? ?? false,
      hasCompletedWebAction: json['hasCompletedWebAction'] as bool? ?? false,
    );

Map<String, dynamic> _$UserMetadataToJson(UserMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'signInCount': instance.signInCount,
      'lastActive': instance.lastActive?.toIso8601String(),
      'recipeGenerationCount': instance.recipeGenerationCount,
      'hasCompletedHomeScreenTutorial': instance.hasCompletedHomeScreenTutorial,
      'hasCompletedTextAction': instance.hasCompletedTextAction,
      'hasCompletedYoutubeAction': instance.hasCompletedYoutubeAction,
      'hasCompletedCameraAction': instance.hasCompletedCameraAction,
      'hasCompletedWebAction': instance.hasCompletedWebAction,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      data: UserData.fromJson(json['data'] as Map<String, dynamic>),
      metadata: UserMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'data': instance.data,
      'metadata': instance.metadata,
    };

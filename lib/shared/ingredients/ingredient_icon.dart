import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/services/firebase/firebase_cache_service.dart';

Widget buildFirebaseNetworkImage({
  required String firebaseImagePath,
  String defaultFirebaseImagePath = 'assets/images/icons/food/default.png',
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, String)? placeholder,
  Widget Function(BuildContext, String, dynamic)? errorWidget,
}) {
  final firebaseCacheService = FirebaseCacheService();

  return FutureBuilder(
    future: firebaseCacheService.getFile(firebaseImagePath),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return placeholder != null
            ? placeholder(context, firebaseImagePath)
            : const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return errorWidget != null
            ? errorWidget(context, firebaseImagePath, snapshot.error)
            : Image.asset(defaultFirebaseImagePath);
      } else {
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          fit: fit,
          cacheKey: firebaseImagePath,
          placeholder: (context, url) => placeholder != null
              ? placeholder(context, url)
              : const CircularProgressIndicator(),
          errorWidget: (context, url, error) => errorWidget != null
              ? errorWidget(context, url, error)
              : Image.asset(defaultFirebaseImagePath),
        );
      }
    },
  );
}

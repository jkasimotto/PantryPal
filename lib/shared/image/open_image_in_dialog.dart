import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/ingredients/ingredient_icon.dart';

void openImageInDialog(
    BuildContext context,
    String firebaseImagePath,
    BoxFit fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: buildFirebaseNetworkImage(
          firebaseImagePath: firebaseImagePath,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
        ),
      );
    },
  );
}

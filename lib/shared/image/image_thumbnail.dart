import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/ingredients/ingredient_icon.dart';

class ImageThumbnail extends StatelessWidget {
  final String? firebaseImagePath;
  final IconData? icon;
  final ImageProvider? image;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final VoidCallback? onTap;

  ImageThumbnail({
    this.firebaseImagePath,
    this.icon,
    this.image,
    this.width = 100.0,
    this.height = 100.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.onTap,
  }) : assert(
            (firebaseImagePath != null && icon == null && image == null) ||
                (firebaseImagePath == null && icon != null && image == null) ||
                (firebaseImagePath == null && icon == null && image != null),
            'Only one of firebaseImagePath, icon, or image should be provided.');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        child: firebaseImagePath != null
            ? buildFirebaseNetworkImage(
                firebaseImagePath: firebaseImagePath!,
                fit: fit,
                placeholder: placeholder,
                errorWidget: errorWidget,
              )
            : (icon != null ? Icon(icon) : Image(image: image!)),
      ),
    );
  }
}

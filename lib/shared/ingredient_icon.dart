import 'dart:developer' as developer;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

Widget buildIngredientIcon(String iconPath) {
  return FutureBuilder(
    future: FirebaseStorage.instance.ref(iconPath).getDownloadURL(),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator(); // Show loading indicator while waiting
      } else {
        if (snapshot.error != null) {
          developer.log('Error occurred: ${snapshot.error}',
              name: 'buildIngredientIcon');
          return const Icon(
              Icons.error); // Show error icon in case of any errors
        } else {
          developer.log('Download URL: ${snapshot.data}',
              name: 'buildIngredientIcon');
          return Image.network(snapshot.data!); // Load the image from the URL
        }
      }
    },
  );
}

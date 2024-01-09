// lib/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/selected_shopping_list_provider.dart';
import 'package:flutter_recipes/screens/collections/list_collection_screen/shopping_list_collection_app_bar.dart';
import 'package:flutter_recipes/screens/collections/list_collection_screen/shopping_list_collection_list_view.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/shared/nav/bottom_nav.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/screens/account/signin_screen.dart';
import 'package:provider/provider.dart';

class ShoppingListCollectionScreen extends StatefulWidget {
  const ShoppingListCollectionScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ShoppingListCollectionScreenState createState() =>
      _ShoppingListCollectionScreenState();
}

class _ShoppingListCollectionScreenState
    extends State<ShoppingListCollectionScreen> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.user;

    if (user == null) {
      return SignInScreen();
    } else {
      return Scaffold(
        appBar: ShoppingListCollectionAppBar(),
        body: const ShoppingListCollectionListView(),
        bottomNavigationBar: BottomNavBar(),
      );
    }
  }
}

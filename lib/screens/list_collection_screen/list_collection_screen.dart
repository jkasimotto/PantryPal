// lib/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_list_view.dart';
import 'package:flutter_recipes/shared/bottom_nav.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/screens/signin_screen.dart';
import 'package:provider/provider.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ListsScreenState createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final AdService adService = AdService();
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.user;
    final GlobalState globalState = Provider.of<GlobalState>(context);

    if (user == null) {
      return SignInScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Lists"),
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: globalState.selectedLists.isNotEmpty
              ? <Widget>[
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      var ids = globalState.selectedLists.keys.toList();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete these items?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () async {
                                  await firestoreService.deleteDocuments(
                                      ids, 'shopping_lists');
                                  setState(() {
                                    globalState.selectedLists.clear();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]
              : null,
        ),
        body: const ListListView(),
        bottomNavigationBar: BottomNavBar(),
      );
    }
  }
}

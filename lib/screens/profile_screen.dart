import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/services/auth_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/shared/bottom_nav.dart';
import 'package:flutter_recipes/models/user/user_model.dart'; // Import the user model
import 'package:flutter_recipes/providers/user_provider.dart'; // Import the user provider
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.background),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // This will create space between the top and bottom widgets
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment
                    .start, // Aligns all children to the start of the column
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: Text(
                              'Subscription Level: ${user.data.subscriptionPlan}'),
                        ),
                        if (user.data.subscriptionPlan == 'free')
                          ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondary, // Set the button color to secondary color
                                ),
                                onPressed: () {
                                  // Update subscription plan to pro
                                  user.data.subscriptionPlan = 'pro';
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .firebaseUser = user;
                                  FirestoreService()
                                      .updateDocument(user, 'users');
                                },
                                child: Text('Upgrade',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.countertops),
                          title: Text(
                            'Recipes created: ${user.metadata.recipeGenerationCount.length}/5',
                          ),
                        ),
                        ListTile(
                          title: SizedBox(
                            height: 10,
                            child: LinearProgressIndicator(
                              value:
                                  user.metadata.recipeGenerationCount.length /
                                      5,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (user.metadata.recipeGenerationCount.length >= 5)
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary, // Set the button color to secondary color
                        ),
                        onPressed: () {
                          // Update subscription plan to pro
                          user.data.subscriptionPlan = 'pro';
                          Provider.of<UserProvider>(context, listen: false)
                              .firebaseUser = user;
                          FirestoreService().updateDocument(user, 'users');
                        },
                        child: const Text('Upgrade to Pro'),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Set the button color to secondary color
                      ),
                      onPressed: () {
                        // Sign out
                        AuthenticationService(FirebaseAuth.instance)
                            .signOut(context);
                      },
                      child: Text('Sign Out',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSecondary)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Set the button color to secondary color
                      ),
                      onPressed: () {
                        // Show confirmation dialog before deleting account
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete your account?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    'Delete',
                                  ),
                                  onPressed: () {
                                    AuthenticationService(FirebaseAuth.instance)
                                        .deleteAccount(context);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Delete Account',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSecondary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

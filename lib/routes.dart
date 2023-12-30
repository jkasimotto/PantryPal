import 'package:flutter/material.dart';
import 'package:flutter_recipes/screens/home_screen/home_screen.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_collection_screen.dart';
import 'package:flutter_recipes/screens/profile_screen.dart'; // Import the ProfileScreen

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/list':
        return MaterialPageRoute(builder: (_) => const ListsScreen());
      case '/account': // Add a new route for the profile screen
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

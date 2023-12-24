import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/bottom_nav_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomNavBarProvider = Provider.of<BottomNavBarProvider>(context);
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      selectedIndex: bottomNavBarProvider.currentIndex,
      onDestinationSelected: (int index) {
        bottomNavBarProvider.onTabTapped(context, index);
      },
      destinations: const [
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.bowlFood),
          label: 'Recipes',
        ),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.list), label: 'Lists'),
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.circleUser),
          label: 'Profile',
        ),
      ],
    );
  }
}

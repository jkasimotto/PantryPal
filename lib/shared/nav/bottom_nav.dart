import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/ui/nav_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavProvider>(context);
    final navService = Provider.of<NavProvider>(context);
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      selectedIndex: navProvider.currentIndex,
      onDestinationSelected: (int index) {
        if (index != navProvider.currentIndex) {
          navService.navigateToScreen(context, index);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.burger),
          label: 'Recipes',
        ),
        NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.list), label: 'Lists'),
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.circleUser),
          label: 'Profile',
        ),
      ],
    );
  }
}

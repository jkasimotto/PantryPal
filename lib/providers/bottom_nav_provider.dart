import 'package:flutter/material.dart';

class BottomNavBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void onTabTapped(BuildContext context, int index) {
    if (_currentIndex != 2 && (index == 0 || index == 1)) {
      // If we are on 0 or 1 and 0 or 1 is pressed, just update current index but don't pushNamedReplacement
      _currentIndex = index;
    } else if (_currentIndex == 2 && (index == 0 || index == 1)) {
      // If we are on 2 and 0 or 1 is pressed, do update namedReplacement
      _currentIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/search');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/search');
          break;
      }
    } else if (index == 2) {
      // If profile is pressed, navigate to profile
      _currentIndex = index;
      Navigator.pushReplacementNamed(context, '/account');
    } else {
      // For any other index, navigate to home
      _currentIndex = index;
      Navigator.pushReplacementNamed(context, '/');
    }
    notifyListeners();
  }
}

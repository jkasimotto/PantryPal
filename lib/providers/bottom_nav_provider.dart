import 'package:flutter/material.dart';

class BottomNavBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void onTabTapped(BuildContext context, int index) {
    if (_currentIndex != 1 && index == 0) {
      // If we are on 0 and 0 is pressed, just update current index but don't pushNamedReplacement
      _currentIndex = index;
    } else if (_currentIndex == 1 && index == 0) {
      // If we are on 1 and 0 is pressed, do update namedReplacement
      _currentIndex = index;
      Navigator.pushReplacementNamed(context, '/search');
    } else if (index == 1) {
      // If profile is pressed, navigate to profile
      _currentIndex = index;
      Navigator.pushReplacementNamed(context, '/list');
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
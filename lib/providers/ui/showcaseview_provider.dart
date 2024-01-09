import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/keys/global_keys.dart';
import 'package:showcaseview/showcaseview.dart';

// TODO: Orchestrate showcases across different screens by chaining them and modifying state accordingly.
class ShowcaseProvider extends ChangeNotifier {
  // Increments to zero the first showcase.
  int _currentShowcase = 0;
  final List<List<GlobalKey>> _showcaseKeys = [
    [recipeCollectionFABAddShowcaseKey],
    [
      recipeCollectionBottomSheetAddListView,
      recipeCollectionCardCheckboxShowcaseKey,
      shoppingListShowcaseKey,
    ]
  ];

  void nextShowcase(BuildContext context) {
    if (_currentShowcase < _showcaseKeys.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        developer.log('Current Showcase: $_currentShowcase',
            name: 'ShowcaseProvider');
        ShowCaseWidget.of(context)
            .startShowCase(_showcaseKeys[_currentShowcase]);
        _currentShowcase++;
        developer.log('Showcase incremented. New value: $_currentShowcase',
            name: 'ShowcaseProvider');
      });
    } else {
      developer.log('No more showcases', name: 'ShowcaseProvider');
    }
  }
}

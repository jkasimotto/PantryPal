// lib/providers/ad_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/services/ad_service.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();

  AdService get adService => _adService;

  AdProvider() {
    _adService.loadInterstitialAd(onAdDismiss: () {}, onAdShown: () {});
  }

  // Add any additional methods or properties you need here
}

// lib/providers/ad_provider.dart
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_recipes/shared/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;

// Import the developer package

class AdService with ChangeNotifier {
  late InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;

  InterstitialAd get interstitialAd => _interstitialAd;

  void loadInterstitialAd(
      {required VoidCallback onAdDismiss, required VoidCallback onAdShown}) {
    developer.log('Loading interstitial ad', name: 'AdService');
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          developer.log('Interstitial ad loaded', name: 'AdService');
          _isInterstitialAdReady = true;
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              developer.log('Interstitial ad showing', name: 'AdService');
              onAdShown();
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              developer.log('Interstitial ad dismissed', name: 'AdService');
              _isInterstitialAdReady = false;
              loadInterstitialAd(
                  onAdDismiss: onAdDismiss, onAdShown: onAdShown);
              onAdDismiss();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          developer.log('Failed to load an interstitial ad: ${error.message}',
              name: 'AdService');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady) {
      developer.log('Interstitial ad not ready', name: 'AdService');
      return;
    }

    developer.log('Showing interstitial ad', name: 'AdService');
    await _interstitialAd.show();
  }
}

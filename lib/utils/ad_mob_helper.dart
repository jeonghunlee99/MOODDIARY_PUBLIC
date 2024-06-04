import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdManager {
  RewardedAd? _rewardedAd;
  final String rewardAdId;

  RewardAdManager({required this.rewardAdId});

  void loadAd() {
    RewardedAd.load(
      adUnitId: rewardAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showAd() {
    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: $reward');
        // Handle reward here
      },
    );
  }
  void dispose() {
    _rewardedAd?.dispose();
  }
}

class NativeAdManager {
  final String adUnitId;
  final String factoryId;

  NativeAdManager({required this.adUnitId, required this.factoryId});

  Future<NativeAd> createNativeAd() {
    final Completer<NativeAd> completer = Completer<NativeAd>();

    final NativeAd nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: factoryId,
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) => completer.complete(ad as NativeAd),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    nativeAd.load();

    return completer.future;
  }
}
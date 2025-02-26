import 'dart:ffi';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
export 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdMobConstants.dart';

final shouldShowAdForThisUser = true;
typedef OnAdShowCompletedCallBack = void Function(bool completed);

class AdMobMobileHelper {
  static const String AdShownDateAndTime = "_AdShownDateAndTime";

  AdMobMobileHelper() {
    MobileAds.instance.initialize();
    List<String> testDevices = ["38AAEFC25EF4FBA6FF3047B66C4D9F3A"]; // redmi
    RequestConfiguration config = RequestConfiguration(
      testDeviceIds: testDevices,
    );
    MobileAds.instance.updateRequestConfiguration(config);
    // GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine,
    //     "adFactoryExample", NativeAdFactoryExample());
    // loadAds();
  }
  loadAds() {
    if (shouldShowAdForThisUser) {
      AdMobMobileHelper.sharedInstance.loadBannerAd();
      AdMobMobileHelper.sharedInstance.loadInterstitialAd();
      AdMobMobileHelper.sharedInstance.loadrewardAd(loadCallBackStatus: (bool ) {  });
    }
  }

  String testAddUnit = "ca-app-pub-3940256099942544/6300978111";
  static AdMobMobileHelper sharedInstance = AdMobMobileHelper();
  //TODO: final AdSize adSize = AdSize.banner;

  BannerAd bannerAd = BannerAd(
    adUnitId: AdMobConstants.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(
      keywords: <String>['gaming', 'puzzle'],
      nonPersonalizedAds: true,
    ),
    listener: BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        // ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  );

  Future<void> loadBannerAd() async {
    if (shouldShowAdForThisUser) {
      await bannerAd.load();
    }
  }

  static var myInterstitialAd;
  static RewardedAd? myRewardAd;

  loadInterstitialAd() {
    if (shouldShowAdForThisUser) {
      InterstitialAd.load(
        adUnitId: AdMobConstants.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print("-----------Interstitial Ad loaded-------");
            // Keep a reference to the ad so you can show it later.
            myInterstitialAd = ad;
            myInterstitialAd
                .fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent:
                  (InterstitialAd ad) =>
                      print('-----------%ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                print('-----------$ad onAdDismissedFullScreenContent.');
                sharedInstance.loadInterstitialAd();
                // ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (
                InterstitialAd ad,
                AdError error,
              ) {
                print(
                  '-----------$ad onAdFailedToShowFullScreenContent: $error',
                );
                // ad.dispose();
              },
              onAdImpression:
                  (InterstitialAd ad) => print('$ad impression occurred.'),
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('-----------InterstitialAd failed to load: $error');
          },
        ),
      );
    }
  }

  showInterstitialAd(
    OnAdShowCompletedCallBack onAdShowCompletedCallBack,
  ) async {
    if (myInterstitialAd == null) {
      loadInterstitialAd();
      onAdShowCompletedCallBack(false);
    } else if (shouldShowAdForThisUser) {
      myInterstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent:
            (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          sharedInstance.loadInterstitialAd();
          print('$ad onAdDismissedFullScreenContent.');
          onAdShowCompletedCallBack(true);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          sharedInstance.loadInterstitialAd();
          onAdShowCompletedCallBack(false);
        },
      );
      myInterstitialAd.show();
    }
  }

  loadrewardAd({required Function(bool) loadCallBackStatus}) {
    if (shouldShowAdForThisUser) {
      RewardedAd.load(
        adUnitId: AdMobConstants.rewardedAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            myRewardAd = ad;
            loadCallBackStatus(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            myRewardAd = null;
            loadCallBackStatus(false);
          },
        ),
      );
    }
  }

  showRewardAd({required Function(bool) isSuccess}) {
    if (myRewardAd == null) {
      loadrewardAd(loadCallBackStatus: (bool status) {
        if (status) {
          // Ad Reward Loaded Success Fully
          showRewardAd(isSuccess: isSuccess);
        } else {
          // Ad Reward Load Failed
          isSuccess(false);
        }
      });
    } else if (shouldShowAdForThisUser) {
      myRewardAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent:
            (RewardedAd ad) => print('$ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          myRewardAd = null;
          isSuccess(false);
        },
        onAdFailedToShowFullScreenContent: (
            RewardedAd ad,
            AdError error,
            ) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          myRewardAd = null;
          isSuccess(false);
        },
        onAdImpression:
            (RewardedAd ad) => print('$ad impression occurred.'),
      );
      myRewardAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          myRewardAd = null;
          isSuccess(true);
        },
      );

    } else {
      myRewardAd = null;
      isSuccess(false);
    }
  }

  shouldShowInterstitialAdToday() async {
    DateTime today = DateTime.now();
    var userdefaults = await SharedPreferences.getInstance();
    String? dbDateStr = userdefaults.getString(AdShownDateAndTime);
    if (dbDateStr == null) {
      return true;
    }

    final dbDate = DateTime.parse(dbDateStr);
    final difference = dbDate.difference(today).inHours;
    // Show Ad every one hour once.
    return difference > 1;
  }

  setInterstitialAdShownToday() async {
    String today = DateTime.now().toIso8601String();
    var userdefaults = await SharedPreferences.getInstance();
    userdefaults.setString(AdShownDateAndTime, today);
  }
}

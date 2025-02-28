import 'dart:io';
abstract class AdMobConstantsProtocol {
}

class AdMobConstants{
  static bool isTestAdsEnabled = false;
  static String get AppID {
    if (isTestAdsEnabled) {
      return TestAdsAdmobConstants.AppID;
    }
    if (Platform.isAndroid) {
      return AdMobConstants._Android_AppID;
    } else if (Platform.isIOS) {
      return AdMobConstants._iOS_AppID;
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
  static String get bannerAdUnitId {
    if (isTestAdsEnabled) {
      return TestAdsAdmobConstants.AdaptiveBannerAds;
    }
    if (Platform.isAndroid) {
      return AdMobConstants._Android_BannerAdID;
    } else if (Platform.isIOS) {
      return AdMobConstants._iOS_BannerAdID;
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (isTestAdsEnabled) {
      return TestAdsAdmobConstants.InterstitialAds;
    }
    if (Platform.isAndroid) {
      return AdMobConstants._Android_InterstitialAdID;
    } else if (Platform.isIOS) {
      return AdMobConstants._iOS_InterstitialAdID;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (isTestAdsEnabled) {
      return TestAdsAdmobConstants.RewardedAds;
    }
    if (Platform.isAndroid) {
      return AdMobConstants._Android_rewardAdID;
    } else if (Platform.isIOS) {
      return AdMobConstants._iOS_rewardAdID;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get nativeAdUnitId {
    if (isTestAdsEnabled) {
      return TestAdsAdmobConstants.NativeAds;
    }
    if (Platform.isAndroid) {
      return AdMobConstants._Android_NativeAdID;
    } else if (Platform.isIOS) {
      return AdMobConstants._iOS_NativeAdID;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static const _Android_AppID = "ca-app-pub-6804393425769663~5375929267";
  static const _Android_BannerAdID = 'ca-app-pub-6804393425769663/8407380733';
  static const _Android_InterstitialAdID = 'ca-app-pub-6804393425769663/8328292017';
  static const _Android_rewardAdID = 'ca-app-pub-6804393425769663/2889366720';
  static const _Android_NativeAdID = 'ca-app-pub-6804393425769663/5727283051';

  static const _iOS_AppID = "ca-app-pub-8433395740188012~5277289904";
  static const _iOS_BannerAdID = "ca-app-pub-8433395740188012/4357291602";
  static const _iOS_InterstitialAdID = "ca-app-pub-8433395740188012/2053194917";
  static const _iOS_rewardAdID = "ca-app-pub-8433395740188012/1700172825";
  static const _iOS_NativeAdID = 'ca-app-pub-6804393425769663/5727283051';
}

class TestAdsAdmobConstants {
  static const AppID = "ca-app-pub-3940256099942544/9257395921";
  static const AdaptiveBannerAds = "ca-app-pub-3940256099942544/9214589741";
  static const FixedBannerAds = "ca-app-pub-3940256099942544/6300978111";
  static const InterstitialAds = "ca-app-pub-3940256099942544/1033173712";
  static const RewardedAds = "ca-app-pub-3940256099942544/5224354917";
  static const RewardedInterstitialAds = "ca-app-pub-3940256099942544/5354046379";
  static const NativeAds = "ca-app-pub-3940256099942544/2247696110";
  static const NativeVideoAds = "ca-app-pub-3940256099942544/1044960115";
}

class NativeAdFactoryConstanst {
  static const NativeAdUnitFactoryIdentifier = "NativeAdUnitFactoryIdentifier";
}
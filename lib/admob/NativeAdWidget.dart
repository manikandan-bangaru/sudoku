import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sudoku/admob/AdMobConstants.dart';
import 'package:sudoku/admob/adMobIntegration.dart';

class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdMobConstants.nativeAdUnitId, // Replace with your AdMob Native Ad Unit ID
      factoryId: NativeAdFactoryConstanst.NativeAdUnitFactoryIdentifier, // Define this in the main widget
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load native ad: $error');
          ad.dispose();
        },
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            height: 100, // Adjust height based on your design
            child: AdWidget(ad: _nativeAd!),
          )
        : SizedBox.shrink();
  }
}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AdMobConstants.dart';
import 'adMobIntegration.dart';

class BannerAdWidget extends StatefulWidget{
  double height = 40.00;
  BannerAdWidget({double height = 40.00});
  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState(height: height);
  }
}

class _BannerAdmobState extends State<BannerAdWidget>{

  late BannerAd _bannerAd;
  bool _bannerReady = false;
  double height = 50.00;
  _BannerAdmobState({required this.height});
  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdMobConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _bannerReady = false;
          });
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerReady?SizedBox(
      width: _bannerAd.size.width.toDouble(),
      height: height,
      child: AdWidget(ad: _bannerAd),
    ):Container(width: _bannerAd.size.width.toDouble(),
        height: height);
  }
}
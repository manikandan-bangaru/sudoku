


import 'package:flutter/cupertino.dart';

import 'AdMobConstants.dart';
import 'adMobIntegration.dart';

class BannerAdWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState();
  }
}

class _BannerAdmobState extends State<BannerAdWidget>{

  late BannerAd _bannerAd;
  bool _bannerReady = false;

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
      height: 40,
      child: AdWidget(ad: _bannerAd),
    ):Container(width: _bannerAd.size.width.toDouble(),
        height: 40);
  }
}
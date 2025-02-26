import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../mixins/app_review_mixin.dart';
import '../../../mixins/share_mixin.dart';
import '../../../utils/game_sizes.dart';


class AboutGameWidget extends StatefulWidget {
  // final bool hideDoneButton ;
  const AboutGameWidget();

  @override
  State<AboutGameWidget> createState() => _AboutGamewidget();
}

class _AboutGamewidget extends State<AboutGameWidget>
    with ShareMixin, AppReviewMixin {

  String _version = "1.1.0";
  String _appName = "Sudoku - Puzzle Game";
  String storeDomainURL = "https://play.google.com/store/apps/details?id=";
  String _packageName = "com.magiban.org.sudoku";
  @override
  void initState() {
    super.initState();
    onStateChange = () => setState(() {});
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _packageName = packageInfo.packageName;
        _appName = packageInfo.appName;
        _version = packageInfo.version + " ( " + packageInfo.buildNumber + " )";
      });
      print(packageInfo.version);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GameSizes.getSymmetricPadding(0.04, 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameIcon(),
          SizedBox(width: GameSizes.getWidth(0.04)),
          _buildGameInfo(),
        ],
      ),
    );
  }

  Widget _buildGameIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/images/play_store_512.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        width: GameSizes.getWidth(0.2),
        height: GameSizes.getWidth(0.2),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$_appName',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: GameSizes.getWidth(0.042),
          ),
        ),
        SizedBox(height: GameSizes.getWidth(0.025)),
        Text(
          'version'.tr(args: ['$_version']),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: GameSizes.getWidth(0.038),
          ),
        ),
        SizedBox(height: GameSizes.getWidth(0.052)),
      ],
    );
  }
}

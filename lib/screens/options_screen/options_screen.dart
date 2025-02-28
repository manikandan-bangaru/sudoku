import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/admob/BannerAdWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../admob/adMobIntegration.dart';
import '../../mixins/app_review_mixin.dart';
import '../../mixins/share_mixin.dart';
import '../../services/localization_manager.dart';
import '../../utils/exports.dart';
import '../../utils/game_routes.dart';
import '../../widgets/button/custom_text_button.dart';
import '../../widgets/option_widgets/exports.dart';
import 'about_game_screen/AboutGameWidget.dart';
import 'options_screen_provider.dart';

class OptionsScreen extends StatefulWidget {
   final bool hideDoneButton ;
  const OptionsScreen({ this.hideDoneButton = false});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState(this.hideDoneButton);
}

class _OptionsScreenState extends State<OptionsScreen>
    with ShareMixin, AppReviewMixin {
  bool hideDoneButton = false;
  _OptionsScreenState(bool hideDoneButton){
    this.hideDoneButton = hideDoneButton;
  }
  String _version = "1.0.0";
  String _appName = "Sudoku- Puzzle Game";
  String storeDomainURL = "https://play.google.com/store/apps/details?id=";
  String _packageName = "com.magiban.org.sudoku";
  @override
  void initState() {
    super.initState();
    onStateChange = () => setState(() {});
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      setState(() {
        _packageName = packageName;
        _appName = appName;
        String buildNumber = packageInfo.buildNumber;
        _version = packageInfo.version + " ( " + buildNumber + " )";
      });
      print(packageInfo.version);
    });
  }
  Future<void> launchPage(String url) async {

    try {
      final Uri uri = Uri.parse(url);
      await canLaunchUrl(uri)
          ? await launchUrl(uri)
          : throw 'Could not launch $url';
    } catch (e) {
      debugPrint(e.toString());
      log('error', name: 'AboutGameScreen', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OptionsScreenProvider>(
      create: (context) => OptionsScreenProvider(),
      child: Consumer<OptionsScreenProvider>(
        builder: ((context, provider, _) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: GameColors.optionsBackground,
              appBar: AppBar(
                elevation: 0.5,
                leadingWidth: 0,
                centerTitle: true,
                backgroundColor: GameColors.appBarBackground,
                title: Text(
                  "Settings",
                  style: GameTextStyles.optionsScreenAppBarTitle
                      .copyWith(fontSize: GameSizes.getWidth(0.045)),
                ),
                leading: const SizedBox.shrink(),
                actions: this.hideDoneButton ? [] : [CustomTextButton(text: "done".tr())],
              ),
              body: SingleChildScrollView(
                padding: GameSizes.getSymmetricPadding(0.04, 0.02),
                child: Column(
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("  Launguage",style: TextStyle(fontSize: 18),),
                      ],
                    ),
                    OptionGroup(
                      options: [
                        OptionWidget(
                          title: LocalizationManager.currentLanguageName,
                          iconColor: Colors.pink,
                          iconData: Icons.language,
                          onTap: () => LocalizationManager.changeLocale(
                              context,
                              LocalizationManager.currentLocale.languageCode ==
                                      'en'
                                  ? LocalizationManager.supportedLocales[0]
                                  : LocalizationManager.supportedLocales[0]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("  Guide",style: TextStyle(fontSize: 18),),
                      ],
                    ),
                    OptionGroup(
                      options: [
                        OptionWidget(
                          title: "howToPlay".tr(),
                          iconColor: Colors.green,
                          iconData: Icons.school,
                          onTap: () => GameRoutes.goTo(GameRoutes.howToPlayScreen,
                              enableBack: true),
                        ),
                        OptionWidget(
                          title: "rules".tr(),
                          iconColor: Colors.lightBlue,
                          iconData: Icons.menu_book_rounded,
                          onTap: () => GameRoutes.goTo(GameRoutes.rulesScreen,
                              enableBack: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("  Privacy",style: TextStyle(fontSize: 18),),
                      ],
                    ),
                    OptionGroup(
                      options: [
                        OptionWidget(
                          title: "privacyPolicy".tr(),
                          iconColor: Colors.red,
                          iconData: Icons.privacy_tip,
                          onTap: () => GameRoutes.goTo(GameRoutes.privacyPolicyScreen,
                              enableBack: true),
                        ),
                        OptionWidget(
                          title: "moreApps".tr(),
                          iconColor: Colors.green,
                          iconData: Icons.apps,
                          onTap: () => GameRoutes.goTo(GameRoutes.moreAppsScreen,
                              enableBack: true),
                        ),
                        OptionWidget(
                          title: "rateUs".tr(),
                          iconColor: Colors.yellow,
                          iconData: Icons.star,
                          loading: reviewLoading,
                          onTap: () => openStoreListing(),
                        ),
                        OptionWidget(
                          title: "share".tr(),
                          iconColor: Colors.orange,
                          iconData: Icons.share,
                          loading: shareLoading,
                          onTap: () => shareApp("shareText".tr(args: [
                            "$storeDomainURL$_packageName"
                          ])),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("  About",style: TextStyle(fontSize: 18),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    AboutGameWidget(),
                    SizedBox(height: 10,),
                    if (shouldShowAdForThisUser) BannerAdWidget(),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/admob/adMobIntegration.dart';
import 'package:sudoku/constant/enums.dart';

import '../../admob/BannerAdWidget.dart';
import '../../mixins/app_review_mixin.dart';
import '../../mixins/share_mixin.dart';
import '../../models/game_model.dart';
import '../../utils/game_colors.dart';
import '../../utils/game_routes.dart';
import '../../utils/game_sizes.dart';
import '../../utils/game_text_styles.dart';
import '../../widgets/app_bar_action_button.dart';
import '../../widgets/button/rounded_button/rounded_button.dart';
import 'main_screen_provider.dart';
import 'package:flutter/material.dart';
class MainScreen extends StatefulWidget {
  // final bool hideDoneButton ;
  final GameModel? savedGame;
  const MainScreen({this.savedGame});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with ShareMixin, AppReviewMixin {
//
// class MainScreen extends StateullWidget {
  GameModel? savedGame;
  MainScreen(GameModel? savedGame) {
    this.savedGame = savedGame;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.mainScreenBg,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: GameSizes.getWidth(0.12),
        backgroundColor: GameColors.mainScreenBg,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const SizedBox.shrink(),
        // actions: [
        //   AppBarActionButton(
        //     onPressed: () =>
        //         GameRoutes.goTo(GameRoutes.optionsScreen, enableBack: true),
        //     icon: Icons.settings_outlined,
        //     iconSize: GameSizes.getWidth(0.08),
        //   ),
        //   SizedBox(width: GameSizes.getWidth(0.02)),
        // ],
      ),
      body: ChangeNotifierProvider<MainScreenProvider>(
        create: (context) => MainScreenProvider(savedGame: savedGame),
        child: Consumer<MainScreenProvider>(builder: (context, provider, _) {
          return
            // Padding(
            // padding: GameSizes.getSymmetricPadding(0.05, 0.02),
            // child:
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const ChallengeAndEvents(),
                const AppLogo(),
                GameTitle(title: "appName".tr(args: [":\n"])),
          SegmentedButton<Difficulty>(
          style:  ButtonStyle(
            side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return BorderSide(color: Colors.blue, width: 2); // Selected border color
                }
                return BorderSide(color: GameColors.roundedButton, width: 1); // Default border color
              },
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                if (states.contains(MaterialState.selected)) {
                  return GameColors.roundedButton; // Selected background
                }
                return GameColors.optionsBackground; // Default background
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white; // Selected foreground
                }
                return GameColors.roundedButton; // Default foreground
              },
            ),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
            ),
          ),
          segments: [
            for (var diff in Difficulty.values)
              ButtonSegment(
              value: diff,
              label: FittedBox(child: Text(diff.name, style: TextStyle(fontSize: 12))),
              // icon: Icon(Icons.one_k_rounded),
            ),
          ],
          selected: <Difficulty>{MainScreenProvider.selectedDificulty},
          onSelectionChanged: (Set<Difficulty> newSelection) async {
          setState(()  {
            MainScreenProvider.selectedDificulty = newSelection.first;
          });
          await provider.storageService.saveDifficulty(newSelection.first);
          },
          ),
                Container(
                  height: GameSizes.getHeight(0.25),
                  padding: GameSizes.getHorizontalPadding(0.05),
                  child: Column(
                    children: [
                      Visibility(
                          visible: provider.isThereASavedGame,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: GameSizes.getHeight(0.02)),
                            child: RoundedButton(
                              buttonText: "continueGame".tr(),
                              subText: provider.continueGameButtonText,
                              subIcon: Icons.watch_later_outlined,
                              onPressed: provider.continueGame,
                              textSize: GameSizes.getHeight(0.02),
                            ),
                          )),
                      RoundedButton(
                        buttonText: "newGame".tr(),
                        whiteButton: provider.isThereASavedGame,
                        elevation: provider.isThereASavedGame ? 5 : 0,
                        onPressed: ()=> provider.newGame(MainScreenProvider.selectedDificulty),
                        textSize: GameSizes.getHeight(0.022),
                      ),
                      Spacer(flex: 1,),
                      if (shouldShowAdForThisUser) BannerAdWidget(),
                    ],
                  ),
                ),
              ],
            // ),
          );
        }),
      ),
    );
  }
}

class GameTitle extends StatelessWidget {
  const GameTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: GameSizes.getHorizontalPadding(0.05),
      child: FittedBox(
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GameTextStyles.mainScreenTitle.copyWith(
              fontSize: GameSizes.getWidth(0.08),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameColors.mainScreenBg,
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: AssetImage('assets/images/play_store_512.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: SizedBox(
        width: GameSizes.getWidth(0.42),
        height: GameSizes.getWidth(0.42),
      ),
    );
  }
}

class ChallengeAndEvents extends StatelessWidget {
  const ChallengeAndEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: GameSizes.getHeight(0.25),
      width: double.infinity,
      padding: GameSizes.getPadding(0.02),
      decoration: BoxDecoration(border: Border.all()),
      child: Center(
        child: Text(
          'This app is being developed by \n @recepsenoglu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: GameSizes.getHeight(0.025),
          ),
        ),
      ),
    );
  }
}

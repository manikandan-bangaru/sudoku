import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/admob/BannerAdWidget.dart';
import 'package:sudoku/admob/adMobIntegration.dart';

import '../../constant/enums.dart';
import '../../constant/game_constants.dart';
import '../../models/stat_group_model.dart';
import '../../models/stat_model.dart';
import '../../utils/game_colors.dart';
import '../../utils/game_routes.dart';
import '../../utils/game_sizes.dart';
import '../../utils/game_strings.dart';
import '../../utils/game_text_styles.dart';
import '../../widgets/app_bar_action_button.dart';
import '../../widgets/option_widgets/option_group_widget.dart';
import '../../widgets/option_widgets/option_widget.dart';
import 'statistics_screen_provider.dart';
import 'package:flutter/widgets.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Difficulty> difficulties = GameSettings.getDifficulties;

    return DefaultTabController(
      length: difficulties.length,
      child: ChangeNotifierProvider<StatisticsScreenProvider>(
        create: (context) => StatisticsScreenProvider(),
        child:
            Consumer<StatisticsScreenProvider>(builder: (context, provider, _) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: GameColors.background,
              appBar: StatisticsAppBar(
                onTimeInterval: provider.changeTimeInterval,
                difficulties: GameSettings.getDifficulties,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (provider.loading) ...[
                    const Center(child: CupertinoActivityIndicator()),
                  ] else ...[
                    Expanded(
                      child: TabBarView(
                        children: List.generate(
                          difficulties.length,
                          (index) => Statistics(
                            provider: provider,
                            statGroupModel:
                                provider.getStatGroup(difficulties[index]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class Statistics extends StatelessWidget {
  const Statistics(
      {required this.statGroupModel, required this.provider, super.key});

  final StatGroupModel statGroupModel;
  final StatisticsScreenProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: GameSizes.getSymmetricPadding(0.05, 0.011),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          GameSettings.getStatisticTypes.length,
          (index) {
            StatisticType statisticType = GameSettings.getStatisticTypes[index];
            return StatisticsGroup(
              groupTitle: statisticType.name,
              statistics: statGroupModel.getStats(statisticType),
            );
          },
        ),
      ),
    );
  }
}

class StatisticsGroup extends StatelessWidget {
  const StatisticsGroup(
      {required this.groupTitle, required this.statistics, super.key});

  final String groupTitle;
  final List<StatModel> statistics;
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: GameSizes.getVerticalPadding(0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupTitle.toLowerCase().tr(),
            style: GameTextStyles.statisticsGroupTitle.copyWith(
              fontSize: GameSizes.getHeight(0.027),
            ),
          ),
          SizedBox(height: GameSizes.getHeight(0.005)),
        OptionGroup(
              options:
                List.generate(
                  statistics.length,
                      (index) {
                    return StatisticCard(statModel: statistics[index], index: index,);
                  },
                ),
              ),
          // Column(
          //   children: List.generate(
          //     statistics.length,
          //     (index) {
          //       return StatisticCard(statModel: statistics[index]);
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  StatisticCard({required this.statModel, required this.index, super.key});

  final StatModel statModel;
  final int index;
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.pink, Colors.indigo];
  static int _currentIndex = 0;
  Color getColor() {
    Color color ;
    if (_currentIndex < colors.length) {
      color =  colors[_currentIndex];
      _currentIndex = _currentIndex + 1;
    } else {
      _currentIndex = 0;
      color = colors[0];
    }
    return  color;
  }
  Widget _GameStatsWidget() {
    return  InkWell(
      onTap:   null ,
      borderRadius: GameSizes.getRadius(6),
      child: Padding(
        padding: GameSizes.getVerticalPadding(0.005),
        child: Row(
          children: [
            SizedBox(width: GameSizes.getWidth(0.01)),
            Container(
              width: GameSizes.getWidth(0.07),
              height: GameSizes.getWidth(0.07),
              padding: GameSizes.getPadding(0.01),
              decoration: BoxDecoration(
                color:  getColor(),
                borderRadius: GameSizes.getRadius(6),
              ),
              child: Center(
                child: FittedBox(
                  child: Icon(
                    getIconData(statModel.title),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: GameSizes.getWidth(0.04)),
            Text(statModel.title,
                style: GameTextStyles.optionButtonTitle
                    .copyWith(fontSize: GameSizes.getWidth(0.04))),
            const Spacer(),
              Text(
                  statModel.value == null ? '-' : statModel.value.toString(),
                  style: GameTextStyles.statisticsCardValue
                      .copyWith(fontSize: GameSizes.getHeight(0.025)),
                ),
            // Icon(
            //   Icons.keyboard_arrow_right,
            //   color: GameColors.greyColor,
            //   size: GameSizes.getWidth(0.07),
            // ),
          ],
        ),
      ),
    );

    //   OptionWidget(
    //   title: statModel.title,
    //   iconColor: GameColors.roundedButton,
    //   iconData:  getIconData(statModel.title),
    //   onTap: null,
    //   loading: false,
    // );
    //   Card(
    //     elevation: 4, // Shadow effect
    //     shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(10), // Rounded corners
    // ),
    // child: Padding(
    // padding: EdgeInsets.all(16),
    // child: Row(
    //       children: [
    //         Icon(getIconData(statModel.title), color: GameColors.roundedButton),
    //         SizedBox(width: 10),
    //         Text(statModel.title),
    //         Spacer(),
    //         Text(
    //           statModel.value == null ? '-' : statModel.value.toString(),
    //           style: GameTextStyles.statisticsCardValue
    //               .copyWith(fontSize: GameSizes.getHeight(0.025)),
    //         ),
    //       ],
    //     ),
    //     // ✅ Show trailing widget if available
    // ),);

  }
  Widget _OldGameStatsWidget() {
    return Container(
      width: double.infinity,
      margin: GameSizes.getVerticalPadding(0.007),
      padding: GameSizes.getPadding(0.045),
      decoration: BoxDecoration(
        color: GameColors.statisticsCard,
        borderRadius: GameSizes.getRadius(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                getIconData(statModel.title),
                color: GameColors.roundedButton,
                size: GameSizes.getHeight(0.038),
              ),
              SizedBox(height: GameSizes.getHeight(0.013)),
              Text(
                statModel.title.toLowerCase().tr(),
                style: GameTextStyles.statisticsCardTitle
                    .copyWith(fontSize: GameSizes.getHeight(0.019)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const ComparisonBox(),
              Text(
                statModel.value == null ? '-' : statModel.value.toString(),
                style: GameTextStyles.statisticsCardValue
                    .copyWith(fontSize: GameSizes.getHeight(0.025)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return (statModel.isAdCell == true) ? (shouldShowAdForThisUser == false) ? Container() : Container(
      child: BannerAdWidget(height: 50,),
      height: 50,
    ): _GameStatsWidget();

  }

  IconData getIconData(String title) {
    switch (title) {
      case GameStrings.gamesStarted:
        return Icons.grid_on_rounded;
      case GameStrings.gamesWon:
        return Icons.workspace_premium_rounded;
      case GameStrings.winRate:
        return Icons.outlined_flag_sharp;
      case GameStrings.winsWithNoMistakes:
        return Icons.sports_score_outlined;
      case GameStrings.bestTime:
        return Icons.timer;
      case GameStrings.averageTime:
        return Icons.timelapse_sharp;
      case GameStrings.bestScore:
        return Icons.star;
      case GameStrings.averageScore:
        return Icons.star_border_purple500;
      case GameStrings.currentWinStreak:
        return Icons.keyboard_double_arrow_right_rounded;
      case GameStrings.bestWinStreak:
        return Icons.double_arrow_sharp;
      default:
        return Icons.grid_on_rounded;
    }
  }
}

class ComparisonBox extends StatelessWidget {
  const ComparisonBox({required this.positive, super.key});

  final bool positive;

  @override
  Widget build(BuildContext context) {
    IconData arrowIcon = positive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: positive ? GameColors.statisticsUp : GameColors.statisticsDown,
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(
            arrowIcon,
            color: Colors.white,
            size: 16,
          ),
          const Text(
            '12',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class StatisticsAppBar extends StatelessWidget implements PreferredSizeWidget {
   StatisticsAppBar(
      {required this.onTimeInterval, required this.difficulties, super.key});

  final Function() onTimeInterval;
  final List<Difficulty> difficulties;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      centerTitle: true,
      backgroundColor: GameColors.appBarBackground,
      title: Text(
        "statistics".tr(),
        style: GameTextStyles.statisticsTitle
            .copyWith(fontSize: GameSizes.getWidth(0.045)),
      ),
      leadingWidth: 0,
      leading: const SizedBox(),
      actions: [
        AppBarActionButton(
          icon: Icons.sort,
          onPressed: onTimeInterval,
          iconSize: GameSizes.getWidth(0.07),
        ),
        SizedBox(width: GameSizes.getWidth(0.025)),
      ],
      bottom:
          PreferredSize(preferredSize: preferredSize, child:  Container(
            height: kToolbarHeight - 8.0,
            decoration: BoxDecoration(
              color: GameColors.optionsBackground,
              borderRadius: BorderRadius.circular(.0),
            ),
            child: TabBar(
              // controller: _tabController,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedColor),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,isScrollable: true,
                tabAlignment: TabAlignment.start,
              tabs:  List.generate(
                  GameSettings.getDifficulties.length,
                      (index) => Tab(
                      child: Text(
                        "  " +GameSettings.getDifficulties[index].name.toLowerCase().tr() + "  ",
                        textAlign: TextAlign.left,
                      ))),
            ),
          ),
          )

      // TabBar(
      //     tabAlignment: TabAlignment.start,
      //     labelColor: _selectedColor, //GameColors.roundedButton,
      //     unselectedLabelColor: _unselectedColor,// GameColors.greyColor,
      //     labelStyle: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       fontSize: GameSizes.getWidth(0.04),
      //     ),
      //     indicator: MaterialDesignIndicator(
      //         indicatorHeight: 4, indicatorColor: _selectedColor),
      //
      //     isScrollable: true,
      //     tabs: List.generate(
      //         GameSettings.getDifficulties.length,
      //         (index) => Tab(
      //                 child: Text(
      //               GameSettings.getDifficulties[index].name.toLowerCase().tr(),
      //               textAlign: TextAlign.left,
      //             )))),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(GameSizes.getWidth(0.25));
  final _selectedColor = Color(0xff1a73e8);
  final _unselectedColor = Color(0xff5f6368);
}

class MaterialDesignIndicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;

  const MaterialDesignIndicator({
    required this.indicatorHeight,
    required this.indicatorColor,
  });

  @override
  _MaterialDesignPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MaterialDesignPainter(this, onChanged);
  }
}

class _MaterialDesignPainter extends BoxPainter {
  final MaterialDesignIndicator decoration;

  _MaterialDesignPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = Offset(
      offset.dx,
      configuration.size!.height - decoration.indicatorHeight,
    ) &
    Size(configuration.size!.width, decoration.indicatorHeight);

    final Paint paint = Paint()
      ..color = decoration.indicatorColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topRight: Radius.circular(8),
        topLeft: Radius.circular(8),
      ),
      paint,
    );
  }
}
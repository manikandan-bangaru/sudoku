import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/admob/BannerAdWidget.dart';

import '../../constant/enums.dart';
import '../../constant/game_constants.dart';
import '../../models/stat_group_model.dart';
import '../../models/stat_model.dart';
import '../../utils/game_colors.dart';
import '../../utils/game_sizes.dart';
import '../../utils/game_strings.dart';
import '../../utils/game_text_styles.dart';
import '../../widgets/app_bar_action_button.dart';
import 'statistics_screen_provider.dart';

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
          return Scaffold(
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
          Column(
            children: List.generate(
              statistics.length,
              (index) {
                return StatisticCard(statModel: statistics[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  const StatisticCard({required this.statModel, super.key});

  final StatModel statModel;

  @override
  Widget build(BuildContext context) {
    return (statModel.isAdCell == true) ? Container(
      child: BannerAdWidget(height: 50,),
      height: 50,
    ): Container(
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
  const StatisticsAppBar(
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
          icon: Icons.tune,
          onPressed: onTimeInterval,
          iconSize: GameSizes.getWidth(0.07),
        ),
        SizedBox(width: GameSizes.getWidth(0.025)),
      ],
      bottom: TabBar(
          tabAlignment: TabAlignment.start,
          labelColor: GameColors.roundedButton,
          unselectedLabelColor: GameColors.greyColor,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: GameSizes.getWidth(0.04),
          ),
          indicatorColor: Colors.transparent,
          isScrollable: true,
          tabs: List.generate(
              GameSettings.getDifficulties.length,
              (index) => Tab(
                      child: Text(
                    GameSettings.getDifficulties[index].name.toLowerCase().tr(),
                    textAlign: TextAlign.left,
                  )))),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(GameSizes.getWidth(0.25));
}

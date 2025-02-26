import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/admob/adMobIntegration.dart';

import '../../admob/BannerAdWidget.dart';
import '../../constant/constants.dart';
import '../../utils/game_colors.dart';
import '../../utils/game_sizes.dart';
import '../../utils/game_strings.dart';
import '../../utils/game_text_styles.dart';
import '../../widgets/button/rounded_button/rounded_button.dart';
import '../../widgets/star_badge_widget.dart';
import '../statistics_screen/statistics_screen_provider.dart';
import 'daily_challenges_screen_provider.dart';

class DailyChallengesScreen extends StatelessWidget {
  const DailyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => DailyChallengesScreenProvider()),
      ChangeNotifierProvider(create: (context) => StatisticsScreenProvider())
    ],
      child: Consumer2<DailyChallengesScreenProvider,StatisticsScreenProvider>(
        builder: (context, dailyProvider, statsProvider, _) {
          return Scaffold(
            // backgroundColor: GameColors.dailyChallengesScreenBg,
            body: Stack(
              children: [
                Column(
                  children: [
                    const TopBlueBox(),
                    CalendarWidget(daily_challenge_provider: dailyProvider,stats_provider: statsProvider,),
                    PlayButton(onPressed: dailyProvider.play),
                    const SizedBox(height: 20),
                    if (shouldShowAdForThisUser) BannerAdWidget(),
                  ],
                ),
                // Image.asset('assets/images/inProgress.png'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    required this.onPressed,
    super.key,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RoundedButton(
        buttonText: GameStrings.play,
        onPressed: onPressed,
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    required this.daily_challenge_provider,
    required this.stats_provider,
    super.key,
  });

  final DailyChallengesScreenProvider daily_challenge_provider;
  final StatisticsScreenProvider stats_provider;
  int daysInCurrentMonth() {
    DateTime now = DateTime.now();
    int days = DateTime(now.year, now.month + 1, 0).day;
    return days;
  }
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final int firstDayOfMonth = now.copyWith(day: 1).weekday;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${months[now.month - 1]} ${now.year}',
                  style: GameTextStyles.calendarDateTitle,
                ),
                const Spacer(),
                StarBadgeWidget(),
                const SizedBox(width: 8),
                Text(
                  '${stats_provider.getChallengeCompletedDaysThisMonth().length}/${daysInCurrentMonth()}',
                  style: GameTextStyles.calendarDateTitle,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  days.length,
                  (index) {
                    return SizedBox(
                      width: 10,
                      child: Text(
                        days[index],
                        textAlign: TextAlign.center,
                        style: GameTextStyles.calendarDays,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                children: List.generate(
                  35,
                  (index) {
                    final int day = index - firstDayOfMonth + 1;
                    final bool isFuture = day > now.day;
                    final bool isCurrentMonth = index >= firstDayOfMonth;
                    final bool isCompleted = isCurrentMonth && stats_provider.getChallengeCompletedDaysThisMonth().contains(day);
                    final bool isStarted = isCurrentMonth && stats_provider.getChallengeOnlyStartedDaysThisMonth().contains(day);
                    final bool isSelected =
                        isCurrentMonth && daily_challenge_provider.selectedDay == day;

                    if (isCompleted) {
                      return StarBadgeWidget(today: day,);
                    }

                    return InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => daily_challenge_provider.selectDay(day),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: getDecoration(isSelected),
                            child: Center(
                              child: Text(
                                isCurrentMonth ? '$day' : '',
                                style: isFuture
                                    ? GameTextStyles.calendarFutureDate
                                    : isSelected
                                        ? GameTextStyles.calendarDateSelected
                                        : GameTextStyles.calendarDate,
                              ),
                            ),
                          ),
                          getProgressIndicator(isStarted, isSelected),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration? getDecoration(bool isSelected) {
    return isSelected
        ? BoxDecoration(
            shape: BoxShape.circle,
            color: GameColors.roundedButton,
          )
        : null;
  }

  Widget getProgressIndicator(bool isStarted, bool isSelected) {
    if (isStarted) {
      return Padding(
        padding: EdgeInsets.all(isSelected ? 4 : 2),
        child: CircularProgressIndicator(
          value: 0.4,
          strokeWidth: 3,
          color: isSelected ? Colors.white : GameColors.roundedButton,
          backgroundColor: isSelected
              ? GameColors.progressBgSelected
              : GameColors.lightGreyColor,
        ),
      );
    }
    return const SizedBox();
  }
}

class TopBlueBox extends StatelessWidget {
  const TopBlueBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: EdgeInsets.only(top: GameSizes.topPadding + 20),
      decoration: BoxDecoration(color: Colors.blue.shade700),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Text(
            GameStrings.dailyChallenges,
            style: GameTextStyles.dailyChallengesTitle,
          ),
          const Icon(Icons.task_alt, size: 180.00,color: Colors.white,),
        ],
      ),
    );
  }
}

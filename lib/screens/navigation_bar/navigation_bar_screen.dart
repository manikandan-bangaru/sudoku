import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../daily_challenges_screen/daily_challenges_screen.dart';
import '../options_screen/options_screen.dart';
import '../options_screen/settings_screen/settings_screen.dart';
import '/utils/game_sizes.dart';

import '../../models/game_model.dart';
import '../../utils/game_colors.dart';
import '../../utils/game_text_styles.dart';
import '../main_screen/main_screen.dart';
import '../statistics_screen/statistics_screen.dart';

class NavigationBarScreen extends StatefulWidget {
  const NavigationBarScreen({
    super.key,
    this.pageIndex,
    this.savedGame,
  });

  final int? pageIndex;
  final GameModel? savedGame;

  @override
  State<NavigationBarScreen> createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
  int _selectedIndex = -1;

  void onTappedItem(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex =
        _selectedIndex == -1 ? (widget.pageIndex ?? 0) : _selectedIndex;

    List<Widget> screens = [
      MainScreen(savedGame: widget.savedGame),
      const DailyChallengesScreen(),
      const StatisticsScreen(),
      const OptionsScreen(hideDoneButton: true,),
      // const SettingsScreen()
    ];
    return Scaffold(
      backgroundColor: GameColors.background,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        onTap: onTappedItem,
        items: navigationBarItems,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: GameColors.navigationBarItemActive,
        unselectedItemColor: GameColors.navigationBarItemPassive,
        selectedLabelStyle: GameTextStyles.navigationBarItemLabel
            .copyWith(fontSize: GameSizes.getWidth(0.032)),
        unselectedLabelStyle: GameTextStyles.navigationBarItemLabel.copyWith(
          fontSize: GameSizes.getWidth(0.032),
        ),
      ),
      body: screens[_selectedIndex],
    );
  }

  List<BottomNavigationBarItem> get navigationBarItems => [
        BottomNavigationBarItem(
          label: "home".tr(),
          icon: Icon(Icons.home, size: GameSizes.getWidth(0.08)),
        ),
    BottomNavigationBarItem(
      label: "Daily Chalange",
      icon: Icon(Icons.calendar_month, size: GameSizes.getWidth(0.08)),
    ),
        BottomNavigationBarItem(
          label: "statistics".tr(),
          icon: Icon(Icons.bar_chart, size: GameSizes.getWidth(0.08)),
        ),

    BottomNavigationBarItem(
      label: "Settings",
      icon: Icon(Icons.settings, size: GameSizes.getWidth(0.08)),
    ),
      ];
}

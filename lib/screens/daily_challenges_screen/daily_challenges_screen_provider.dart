import 'package:flutter/widgets.dart';
import '/constant/enums.dart';
import '/constant/game_constants.dart';
import '/models/game_model.dart';
import '/utils/game_routes.dart';

class DailyChallengesScreenProvider with ChangeNotifier {
  int selectedDay = -1;
  late DateTime selectedDate;
  late final DateTime now;
  bool get daySelected => selectedDay != -1;

  DailyChallengesScreenProvider() {
    now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    selectedDay = now.day;
  }

  void play() {
    if (daySelected) {
      _createGame();
    }
  }

  void selectDay(int day) {
    if (day > 0 && now.day >= day) {
      selectedDay = day;
      notifyListeners();
    }
  }

  void _createGame() {
    final List<Difficulty> difficulties = List<Difficulty>.from(
        GameSettings.getDifficulties.where((e) => e.index < 3));

    difficulties.shuffle();

    final GameModel gameModel = GameModel(
      sudokuBoard: GameSettings.createSudokuBoard(),
      difficulty: difficulties[0],
      dailyChallenge: true,
    );

    GameRoutes.goTo(GameRoutes.gameScreen, args: gameModel);
  }
}

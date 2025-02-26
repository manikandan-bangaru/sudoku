import 'package:flutter/material.dart';
import '/constant/enums.dart';
import '/constant/game_constants.dart';
import '/models/game_model.dart';
import '/utils/game_routes.dart';
import '/widgets/modal_bottom_sheet/modal_bottom_sheets.dart';

class WinScreenProvider with ChangeNotifier {
  late final GameModel gameModel;

  WinScreenProvider(GameModel gameModelP) {
    gameModel = gameModelP;
  }

  Future<void> newGame() async {
    Difficulty? newGameDifficulty = await ModalBottomSheets.chooseDifficulty();

    if (newGameDifficulty != null) {
      final GameModel gameModel = GameModel(
        sudokuBoard: GameSettings.createSudokuBoard(),
        difficulty: newGameDifficulty,
      );

      GameRoutes.goTo(GameRoutes.gameScreen, args: gameModel);
    }
  }
}

import 'package:flutter/material.dart';
import '/constant/enums.dart';
import '/constant/game_constants.dart';
import '/models/game_model.dart';
import '/utils/game_routes.dart';
import '/services/storage_service.dart';
import '/utils/extensions.dart';
import '/widgets/modal_bottom_sheet/modal_bottom_sheets.dart';

class MainScreenProvider with ChangeNotifier {
  GameModel? savedGame;

  MainScreenProvider({this.savedGame}) {
    _init();
  }

  Future<void> _init() async {
    StorageService storageService = await StorageService.initialize();

    savedGame = storageService.getSavedGame();
    notifyListeners();
  }

  bool get isThereASavedGame => savedGame != null;

  String get continueGameButtonText => isThereASavedGame
      ? '${savedGame!.time.toTimeString()} - ${savedGame!.difficulty.name}'
      : '';

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

  void continueGame() {
    if (isThereASavedGame) {
      GameRoutes.goTo(GameRoutes.gameScreen, args: savedGame);
    }
  }
}

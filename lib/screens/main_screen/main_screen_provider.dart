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
  Difficulty selectedDificulty = Difficulty.Easy;
  MainScreenProvider({this.savedGame}) {
    _init();
  }
  late StorageService storageService;
  Future<void> _init() async {
    storageService = await StorageService.initialize();
    selectedDificulty = await this.getDiffiCulty();
    savedGame = storageService.getSavedGame();
    notifyListeners();
  }
  Future<void> saveDiffiCulty(Difficulty diff) async {
    this.selectedDificulty = diff;
    await storageService.saveDifficulty(diff);
  }
  Future<Difficulty> getDiffiCulty() async {

   return await storageService.getDifficulty();
  }

  bool get isThereASavedGame => savedGame != null;

  String get continueGameButtonText => isThereASavedGame
      ? '${savedGame!.time.toTimeString()} - ${savedGame!.difficulty.name}'
      : '';

  Future<void> newGame(Difficulty diff) async {
    // Difficulty? newGameDifficulty = await ModalBottomSheets.chooseDifficulty();

    // if (diff != null) {
      final GameModel gameModel = GameModel(
        sudokuBoard: GameSettings.createSudokuBoard(),
        difficulty: diff,
      );

      GameRoutes.goTo(GameRoutes.gameScreen, args: gameModel);
    // }
  }

  void continueGame() {
    if (isThereASavedGame) {
      GameRoutes.goTo(GameRoutes.gameScreen, args: savedGame);
    }
  }
}

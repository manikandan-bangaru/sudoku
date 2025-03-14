import '/constant/enums.dart';
import '/models/board_model.dart';
import '/models/cell_model.dart';
import '/models/cell_position_model.dart';

class GameSettings {
  static BoardModel createSudokuBoard() {
    List<List<CellModel>> cells = List.generate(
        9,
        (y) => List.generate(
            9,
            (x) => CellModel(
                  position: CellPositionModel(y: y, x: x),
                  realValue: 0,
                  notes: [],
                )));

    return BoardModel(cells: cells, movesLog: []);
  }

  static List<StatisticType> get getStatisticTypes => [
        StatisticType.Games,
        StatisticType.Time,
        StatisticType.Score,
        StatisticType.Streaks
      ];

  static List<Difficulty> get getDifficulties => Difficulty.values;

  static List<TimeInterval> get getTimeIntervals => TimeInterval.values;

  static int amountOfNumbersGiven(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.Easy:
        return 38;
      case Difficulty.Medium:
        return 30;
      case Difficulty.Hard:
        return 28;
      case Difficulty.Expert:
        return 22;
      case Difficulty.Master:
        return 23;
      default:
        return 30;
    }
  }
}

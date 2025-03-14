import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '/utils/game_strings.dart';
import '/constant/enums.dart';
import '/constant/game_constants.dart';
import '/models/game_stats_model.dart';
import '/models/stat_group_model.dart';
import '/models/stat_model.dart';
import '/models/statistics_model.dart';
import '/services/storage_service.dart';
import '/utils/extensions.dart';
import '/widgets/modal_bottom_sheet/modal_bottom_sheets.dart';

class StatisticsScreenProvider with ChangeNotifier {
  late StorageService _storageService;
  late StatisticsModel statisticsModel = StatisticsModel(statistics: [], statGroups: []);

  bool loading = true;

  TimeInterval timeInterval = TimeInterval.All_time;

  StatisticsScreenProvider() {
    statisticsModel = StatisticsModel(statistics: [], statGroups: []);
    _init();
  }

  List<GameStatsModel> getStatisticsByTime(TimeInterval this_month) {
    final DateTime now = DateTime.now();
    List<GameStatsModel> gameStats = statisticsModel.statistics;
    var currTimeInterval = timeInterval ?? this.timeInterval;
    if (currTimeInterval == TimeInterval.All_time) {
      return gameStats;
    } else if (currTimeInterval == TimeInterval.This_year) {
      if (gameStats.any((element) => element.dateTime.year == now.year)) {
        return gameStats
            .where((element) => element.dateTime.year == now.year)
            .toList();
      }
    } else if (currTimeInterval == TimeInterval.This_month) {
      if (gameStats.any((element) =>
          element.dateTime.month == now.month &&
          now.difference(element.dateTime).inDays < 31)) {
        return gameStats
            .where((element) => element.dateTime.month == now.month)
            .toList();
      }
    } else if (currTimeInterval == TimeInterval.This_week) {
      if (gameStats.any((element) =>
          now.difference(element.dateTime).inDays <= now.weekday)) {
        return gameStats
            .where((element) =>
                now.difference(element.dateTime).inDays <= now.weekday)
            .toList();
      }
    } else if (currTimeInterval == TimeInterval.Today) {
      if (gameStats.any((element) =>
          now.day == element.dateTime.day &&
          now.difference(element.dateTime).inDays < 1)) {
        return gameStats
            .where((element) => now.difference(element.dateTime).inDays < 1)
            .toList();
      }
    }

    return [];
  }

  void _setStatGroups() {
    statisticsModel.statGroups.clear();
    final List<GameStatsModel> statisticsByTime = getStatisticsByTime(this.timeInterval);

    for (Difficulty difficulty in GameSettings.getDifficulties) {
      List<GameStatsModel> gameStats = [];

      final bool difficultyRecordExists =
          statisticsByTime.any((element) => element.difficulty == difficulty);

      if (difficultyRecordExists) {
        gameStats = statisticsByTime
            .where((element) => element.difficulty == difficulty)
            .toList();
      }

      final StatGroupModel statGroupModel = StatGroupModel(
        difficulty: difficulty,
        stats: _setStats(gameStats),
      );

      statisticsModel.statGroups.add(statGroupModel);
    }
  }
  Set<int> getChallengeCompletedDaysThisMonth() {
    _getAllStatistics;
    Set<int> result = Set<int>();
    final List<GameStatsModel> statisticsByThisMonthTime = getStatisticsByTime(TimeInterval.This_month);

    for (var stats in statisticsByThisMonthTime) {
     if ( stats.won == true) {
          int day = stats.dateTime.day;
          result.add(day);
     }
    }
    result.length > 0 ? debugPrint("DEBUG completed: $result"):debugPrint("$result");
    return result;
  }
  Set<int> getChallengeOnlyStartedDaysThisMonth() {
    _getAllStatistics;
    Set<int> result = Set<int>();
    final List<GameStatsModel> statisticsByThisMonthTime = getStatisticsByTime(TimeInterval.This_month);
    final completedDays = getChallengeCompletedDaysThisMonth();
    for (var stats in statisticsByThisMonthTime) {
      if ( stats.won == false) {
        int day = stats.dateTime.day;
        if (completedDays.contains(day) == false) {
          result.add(day);
        }
      }
    }
    result.length > 0 ? debugPrint("DEBUG Not completed: $result"):debugPrint("$result");
    return result;
  }

  List<StatModel> _setStats(List<GameStatsModel> gameStats) {
    List<StatModel> stats = [];
    gameStats.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    int? gamesStarted;
    int? gamesWon;
    int? winRate;
    int? winsWithNoMistakes;
    int? bestTime;
    int? averageTime;
    int? bestScore;
    int? averageScore;
    int? currentWinStreak;
    int? bestWinStreak;

    if (gameStats.isNotEmpty) {
      /// Games
      gamesStarted = gameStats.length;
      gamesWon = gameStats.where((element) => element.won == true).length;
      winRate = ((gamesWon * 100) / gamesStarted).round();
      winsWithNoMistakes = gameStats
          .where((element) => element.won == true && element.mistakes == 0)
          .length;

      /// Time
      final List<int> times = gameStats
          .where((element) => element.time != null && element.won == true)
          .toList()
          .map((e) => e.time!)
          .toList();

      bestTime = times.isNotEmpty ? times.reduce(max) : null;
      averageTime = times.isNotEmpty
          ? times.fold(0, (previousValue, element) => previousValue! + element)
          : null;

      /// Score
      final List<int> scores = gameStats
          .where((element) => element.score != null)
          .toList()
          .map((e) => e.score!)
          .toList();

      bestScore = scores.isNotEmpty ? scores.reduce(max) : null;
      averageScore = scores.isNotEmpty
          ? scores.fold(0, (previousValue, element) => previousValue! + element)
          : null;

      /// Streaks
      gameStats.removeWhere((element) => element.won == null);

      if (gameStats.every((element) => element.won == true)) {
        currentWinStreak = gameStats.length;
      } else {
        currentWinStreak =
            gameStats.indexWhere((element) => element.won == false);
        if (currentWinStreak == -1) {
          currentWinStreak = 0;
        }
      }

      int currentConsecutiveWins = 0;
      bestWinStreak = 0;

      for (int i = 0; i < gameStats.length; i++) {
        if (gameStats[i].won == true) {
          currentConsecutiveWins++;
          if (currentConsecutiveWins > bestWinStreak!) {
            bestWinStreak = currentConsecutiveWins;
          }
        } else {
          currentConsecutiveWins = 0;
        }
      }
    }

    /// add Stats
    stats.add(StatModel(
      index: 0,
      value: gamesStarted,
      title: GameStrings.gamesStarted,
      type: StatisticType.Games,
    ));
    stats.add(StatModel(
      index: 1,
      value: gamesWon,
      title: GameStrings.gamesWon,
      type: StatisticType.Games,
    ));
    stats.add(StatModel(
      index: 2,
      value: winRate != null ? '$winRate%' : null,
      title: GameStrings.winRate,
      type: StatisticType.Games,
    ));
    stats.add(StatModel(
      index: 3,
      value: winsWithNoMistakes,
      title: GameStrings.winsWithNoMistakes,
      type: StatisticType.Games,
    ));
    stats.add(StatModel(
      index: 0,
      value: bestTime != null ? bestTime.toTimeString() : '-',
      title: GameStrings.bestTime,
      type: StatisticType.Time,
    ));
    stats.add(StatModel(
      index: 1,
      value: averageTime != null ? averageTime.toTimeString() : '-',
      title: GameStrings.averageTime,
      type: StatisticType.Time,
    ));
    stats.add(StatModel(
      index: 0,
      value: bestScore,
      title: GameStrings.bestScore,
      type: StatisticType.Score,
    ));
    stats.add(StatModel(
      index: 1,
      value: averageScore,
      title: GameStrings.averageScore,
      type: StatisticType.Score,
    ));
    stats.add(StatModel(
      index: 0,
      value: currentWinStreak,
      title: GameStrings.currentWinStreak,
      type: StatisticType.Streaks,
    ));
    stats.add(StatModel(
      index: 1,
      value: bestWinStreak,
      title: GameStrings.bestWinStreak,
      type: StatisticType.Streaks,
    ));
    //MARK:  Adding Ads here
    //TODO: This is Native Ad Cell
    stats.add(StatModel(
      index: 2,
      value: 0,
      title: '',
      type: StatisticType.Streaks,
      isAdCell: true,
    ));
    return stats;
  }

  StatGroupModel getStatGroup(Difficulty difficulty) {
    List<StatGroupModel> statGroups = statisticsModel.statGroups
        .where((element) => element.difficulty == difficulty)
        .toList();

    return statGroups.first;
  }

  Future<void> changeTimeInterval() async {
    TimeInterval? selectedTimeInterval;
    try {
      selectedTimeInterval =
          await ModalBottomSheets.chooseTimeInterval(timeInterval);
    } catch (e) {
      dev.log(e.toString(), error: e);
    }

    if (selectedTimeInterval != null && timeInterval != selectedTimeInterval) {
      timeInterval = selectedTimeInterval;
      _setStatGroups();

      notifyListeners();
    }
  }

  void _getAllStatistics() {
    statisticsModel = StatisticsModel(statistics: [], statGroups: []);

    for (Difficulty difficulty in Difficulty.values) {
      StatisticsModel? statistics = _storageService.getStatistics(difficulty);
      if (statistics != null) {
        statisticsModel.statistics.addAll(statistics.statistics);
      }
    }
  }

  Future<void> _init() async {
    _storageService = await StorageService.initialize();

    _getAllStatistics();
    _setStatGroups();

    loading = false;
    notifyListeners();
  }
}

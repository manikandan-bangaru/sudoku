import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/enums.dart';
import '../models/game_model.dart';
import '../models/game_stats_model.dart';
import '../models/statistics_model.dart';

class StorageService {
  late final SharedPreferences _prefs;

  StorageService._create();

  static Future<StorageService> initialize() async {
    StorageService storageService = StorageService._create();
    storageService._prefs = await SharedPreferences.getInstance();
    return storageService;
  }
   Future<void> saveAppIsOpened() async {
    int count = await getNumberOfAppOpenedCount();
    count += 1;
    await _prefs.setInt('game_opened_count', count);
  }

   Future<int> getNumberOfAppOpenedCount() async {
    return _prefs.getInt('game_opened_count') ?? 0;
  }

  Future<void> saveDifficulty(Difficulty diff) async {
    await _prefs.setString('game_difficulty', diff.name);
  }
  Future<Difficulty> getDifficulty() async {
    String? diff = _prefs.getString('game_difficulty');
    Difficulty result = Difficulty.Easy;
    if (diff == Difficulty.Easy.name) {
      result = Difficulty.Easy;
    } else if (diff == Difficulty.Medium.name) {
      result = Difficulty.Medium;
    } else if (diff == Difficulty.Hard.name) {
      result = Difficulty.Hard;
    } else if (diff == Difficulty.Expert.name) {
      result = Difficulty.Expert;
    } else if (diff == Difficulty.Master.name) {
      result = Difficulty.Master;
    }
    return result;
  }

  Future<void> saveGame(GameModel gameModel) async {
    await _prefs.setString('game', jsonEncode(gameModel.toJson()));
  }

  Future<void> deleteGame() async {
    try {
      await _prefs.setString('game', '');
    } catch (e) {
      debugPrint('Error while deleting game: $e');
    }
  }

  GameModel? getSavedGame() {
    if (_prefs.containsKey('game')) {
      debugPrint('Getting saved game');
      String jsonString = _prefs.getString('game')!;
      if (jsonString.isNotEmpty) {
        debugPrint('Saved game found');
        try {
          GameModel gameModel = GameModel.fromJson(jsonDecode(jsonString));
          return gameModel;
        } catch (e) {
          debugPrint('Error while getting saved game: $e');
          return null;
        }
      }
      return null;
    }
    return null;
  }

  Future<void> saveGameStats(GameStatsModel gameStatsModel) async {
    StatisticsModel? statistics = getStatistics(gameStatsModel.difficulty);
    statistics ??= StatisticsModel(statistics: [], statGroups: []);

    if (statistics.statistics.isEmpty || gameStatsModel.isOnGoing) {
      statistics.statistics.add(gameStatsModel);
    } else {
      statistics.updateLast(gameStatsModel);
    }

    try {
      await _prefs.setString('statistics_${gameStatsModel.difficulty}',
          jsonEncode(statistics.toJson()));
    } catch (e) {
      debugPrint('Error while saving game stats: $e');
    }
  }

  StatisticsModel? getStatistics(Difficulty difficulty) {
    if (_prefs.containsKey('statistics_$difficulty')) {
      String jsonString = _prefs.getString('statistics_$difficulty')!;
      try {
        StatisticsModel statisticsModel =
            StatisticsModel.fromJson(jsonDecode(jsonString));
        return statisticsModel;
      } catch (e) {
        debugPrint('Error while getting statistics: $e');
        return null;
      }
    }
    return null;
  }
}

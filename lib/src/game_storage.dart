import 'dart:collection';
import 'dart:convert';

import 'package:mcr_tracker/src/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

const gamePrefix = 'game';

class GameStorage {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static final Map<String, Game> _games = HashMap();
  UnmodifiableMapView<String, Game> get games => UnmodifiableMapView(_games);

  Future<String> newGame({required Set<Player> players}) async {
    final Game game = Game(players: players);
    final String gameId = await saveGame(game: game);

    return gameId;
  }

  Future<void> loadAllGames() async {
    final Set<String> keys = await _prefs.getKeys();
    keys.retainWhere((key) => key.startsWith('$gamePrefix.'));

    for (final String key in keys) {
      final String gameId = key.substring(gamePrefix.length + 1);
      final Game game = await loadGame(gameId: gameId, reload: true);
      _games[gameId] = game;
    }
  }

  Future<String> saveGame({required Game game}) async {
    final String gameId = game.startTime.millisecondsSinceEpoch.toString();
    final String gameJson = jsonEncode(game.toJson());

    _games[gameId] = game;
    await _prefs.setString('$gamePrefix.$gameId', gameJson);
    return gameId;
  }

  Future<Game> loadGame({required String gameId, bool reload = false}) async {
    if (!reload && _games.containsKey(gameId)) {
      return _games[gameId]!;
    }

    final String? gameJson = await _prefs.getString('$gamePrefix.$gameId');
    if (gameJson != null) {
      return Game.fromJson(jsonDecode(gameJson));
    }

    throw GameNotFoundException(gameId);
  }

  Future<void> deleteGame({required String gameId}) async {
    await _prefs.remove('$gamePrefix.$gameId');
  }
}

class GameNotFoundException implements Exception {
  GameNotFoundException(this.gameId);

  final String gameId;

  @override
  String toString() {
    return 'Game $gameId not found';
  }
}

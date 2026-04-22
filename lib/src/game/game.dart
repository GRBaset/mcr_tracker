import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:mcr_tracker/src/game/penalty.dart';
import 'package:mcr_tracker/src/game/scores.dart';
import '../game_storage.dart';
import 'hand.dart';
import 'player.dart';
import 'types.dart';

export 'hand.dart';
export 'penalty.dart';
export 'player.dart';
export 'types.dart';
export 'scores.dart';

class Game {
  Game._internal({
    required this.storage,
    required this.players,
    required this.startTime,
    this.endTime,
  });

  final DateTime startTime;
  DateTime? endTime;
  final Set<Player> players;
  final GameStorage storage;

  final Map<HandNumber, HandEnd> _hands = SplayTreeMap();
  final Map<HandNumber, List<Penalty>> _penalties = SplayTreeMap();
  final List<({HandNumber handNumber, HandEnd hand})> _deletedHands = [];

  UnmodifiableListView<Player> get playersSorted =>
      UnmodifiableListView(players.sorted((a, b) => a.compareTo(b)));
  UnmodifiableMapView<HandNumber, HandEnd> get hands =>
      UnmodifiableMapView(_hands);
  UnmodifiableMapView<HandNumber, List<Penalty>> get penalties =>
      UnmodifiableMapView(_penalties);
  Iterable<HandNumber> get handNumbers =>
      Iterable.generate(currentHandNumber.number + 2, (n) => HandNumber(n));

  bool get finished => endTime != null;
  HandNumber get currentHandNumber {
    final HandNumber lastHand = _hands.keys.lastOrNull ?? HandNumber(-1);
    final HandNumber lastPenalty = _penalties.keys.lastOrNull ?? HandNumber(-1);
    return (lastPenalty.compareTo(lastHand) > 0 ? lastPenalty : lastHand) +
        (finished ? -1 : 0);
  }

  bool get withExtraPlayer => players.length > 4;
  bool get canRestore => _deletedHands.isNotEmpty;

  Future<void> _save() async => await storage.saveGame(game: this);

  Future<void> finish({DateTime? endTime, bool save = true}) async {
    this.endTime = endTime ?? DateTime.timestamp();
    if (save) await _save();
  }

  Future<void> resume() async {
    endTime = null;
    await _save();
  }

  Future<void> addPenalty({
    required Penalty penalty,
    HandNumber? handNumber,
  }) async {
    if (finished) throw GameFinishedException();

    final HandNumber penaltyhandNumber = handNumber ?? currentHandNumber;
    if (!_penalties.containsKey(penaltyhandNumber)) {
      _penalties[penaltyhandNumber] = [];
    }
    _penalties[penaltyhandNumber]!.add(penalty);

    await _save();
  }

  Future<void> removePenalty({
    required HandNumber handNumber,
    required int? index,
  }) async {
    if (finished) throw GameFinishedException();
    if (!_penalties.containsKey(handNumber)) return;

    if (index == null) {
      _penalties[handNumber]!.removeLast();
    } else if (index < _penalties[handNumber]!.length) {
      _penalties[handNumber]!.removeAt(index);
    } else {
      return;
    }

    if (_penalties[handNumber]!.isEmpty) _penalties.remove(handNumber);

    await _save();
  }

  Future<void> addHand({required HandEnd hand}) async {
    if (finished) throw GameFinishedException();
    _hands[currentHandNumber + 1] = hand;
    // TODO: allow for customization, currently we finish on 16th hand
    if (currentHandNumber.number >= 16) finish(save: false);
    await _save();
  }

  Future<void> updateHand({
    required HandNumber handNumber,
    required HandEnd hand,
  }) async {
    if (finished) throw GameFinishedException();
    _hands[handNumber] = hand;
    await _save();
  }

  Future<void> removeHand({required HandNumber handNumber}) async {
    if (finished) throw GameFinishedException();
    if (!_hands.containsKey(handNumber)) return;

    _deletedHands.add((handNumber: handNumber, hand: _hands[handNumber]!));
    _hands.remove(handNumber);
    await _save();
  }

  Future<void> restoreLastHand() async {
    if (finished) throw GameFinishedException();
    if (!canRestore) return;

    final HandNumber handNumber = _deletedHands.last.handNumber;
    final HandEnd hand = _deletedHands.last.hand;
    _hands[handNumber] = hand;
    _deletedHands.removeLast();
    await _save();
  }

  Position playerPosition(Player player, {HandNumber? handNumber}) =>
      player.currentPosition(
        handNumber: handNumber ?? currentHandNumber,
        withExtraPlayer: withExtraPlayer,
      );

  bool isPlaying(Player player, {HandNumber? handNumber}) =>
      playerPosition(player, handNumber: handNumber) != Position.extra;

  Iterable<Player> playersPlaying({HandNumber? handNumber}) =>
      players.where((player) => isPlaying(player, handNumber: handNumber));

  GameScores gameScores() {
    GameScores gameScores = GameScores({});

    for (final HandNumber handNumber in handNumbers) {
      final HandEnd? hand = _hands[handNumber];
      final List<Penalty>? handPenalties = _penalties[handNumber];
      final Iterable<Player> playersPlaying = this.playersPlaying(
        handNumber: handNumber,
      );

      HandScores handScores = HandScores(
        endScores: hand?.playerScores(playersPlaying),
        penaltyScores:
            handPenalties
                ?.map((penalty) => penalty.playerScores(playersPlaying))
                .toList(),
      );

      gameScores[handNumber] = handScores;
    }

    return gameScores;
  }

  PlayerScores playerTotalScores() {
    return gameScores().sum(players);
  }

  factory Game({
    required Set<Player> players,
    DateTime? startTime,
    DateTime? endTime,
    GameStorage? storage,
  }) {
    final int playerNumber = players.length;

    if (playerNumber != 4 && playerNumber != 5) {
      throw ArgumentError('There must be 4 or 5 players.');
    }

    final Set<Position> playerPositions =
        players.map((player) => player.initialPosition).toSet();

    if (playerPositions.length != playerNumber) {
      throw ArgumentError('The players must have unique initial positions.');
    }

    if (playerPositions.difference({Position.extra}).length != 4) {
      throw ArgumentError(
        'There must be at least 4 players with wind (not extra) positions.',
      );
    }

    return Game._internal(
      storage: storage ?? GameStorage(),
      players: players,
      startTime: startTime ?? DateTime.timestamp(),
      endTime: endTime,
    );
  }

  factory Game.fromJson(Map<String, Object?> json, {GameStorage? storage}) {
    if (!json.containsKey('endTime')) json['endTime'] = null;
    if (!json.containsKey('penalties')) json['penalties'] = null;

    if (json case {
      'players': final List<Object?> jsonPlayers,
      'startTime': final String startTimeString,
      'endTime': final String? endTimeString,
      'hands': final List<Object?> jsonHands,
      'penalties': final Map<String, Object?>? jsonPenalties,
    }) {
      final Set<Player> players =
          jsonPlayers
              .map((json) => Player.fromJson(json as Map<String, Object?>))
              .toSet();
      final Game game = Game(
        storage: storage,
        players: players,
        startTime: DateTime.parse(startTimeString),
      );
      final DateTime? endTime = DateTime.tryParse(endTimeString ?? '');

      for (final hand in jsonHands) {
        if (hand is Map<String, Object?>) {
          if (!hand.containsKey('endTime')) hand['endTime'] = null;

          game.addHand(hand: HandEnd.fromJson(hand, players: game.players));
        }
      }

      if (jsonPenalties != null) {
        jsonPenalties.forEach((handNumber, handPenalties) {
          if (handPenalties is List<Object?>) {
            for (final penalty in handPenalties) {
              if (penalty is Map<String, Object?>) {
                game.addPenalty(
                  penalty: Penalty.fromJson(penalty, players: game.players),
                  handNumber: HandNumber(int.parse(handNumber)),
                );
              }
            }
          }
        });
      }

      if (endTime != null) game.finish(endTime: endTime);
      return game;
    }

    throw FormatException('Could not deserialize Game, json=$json');
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'players': players.map((player) => player.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'finished': finished,
    'hands': _hands.values.toList(),
    'penalties': _penalties.map(
      (handNumber, penalties) => MapEntry(handNumber.toString(), penalties),
    ),
  };
}

class GameFinishedException implements Exception {
  GameFinishedException();

  @override
  String toString() {
    return 'Game finished, cannot modify.';
  }
}

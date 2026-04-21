import 'package:collection/collection.dart';
import '../game_storage.dart';
import 'hand.dart';
import 'player.dart';
import 'types.dart';

export 'hand.dart';
export 'player.dart';
export 'types.dart';

extension on PlayerScores {
  PlayerScores operator +(PlayerScores? other) {
    if (other == null) return this;

    return map((player, score) {
      score += other[player] ?? 0;
      return MapEntry(player, score);
    });
  }
}

class Game {
  Game._internal({
    required this.players,
    required this.startTime,
    this.endTime,
  });

  final DateTime startTime;
  DateTime? endTime;
  final Set<Player> players;
  final List<Hand> _hands = [];
  final List<({HandNumber handNumber, Hand hand})> _deletedHands = [];
  final GameStorage _storage = GameStorage();

  bool get finished => endTime != null;
  UnmodifiableListView<Player> get playersSorted =>
      UnmodifiableListView(players.sorted((a, b) => a.compareTo(b)));
  UnmodifiableListView<Hand> get hands => UnmodifiableListView(_hands);
  HandNumber get currentHandNumber =>
      finished ? HandNumber(_hands.length - 1) : HandNumber(_hands.length);
  bool get withExtraPlayer => players.length > 4;
  bool get canRestore => _deletedHands.isNotEmpty;

  Future<void> _save() async => await _storage.saveGame(game: this);

  Future<void> finish({DateTime? newEndTime, bool save = true}) async {
    endTime = newEndTime ?? DateTime.timestamp();
    if (save) await _save();
  }

  Future<void> resume() async {
    endTime = null;
    await _save();
  }

  Future<void> addHand({required Hand hand}) async {
    if (finished) throw GameFinishedException();
    _hands.add(hand);
    // TODO: allow for customization, currently we finish on 16th hand
    if (_hands.length >= 16) finish(save: false);
    await _save();
  }

  Future<void> updateHand({
    required HandNumber handNumber,
    required Hand hand,
  }) async {
    if (finished) throw GameFinishedException();
    _hands[handNumber.number] = hand;
    await _save();
  }

  Future<void> removeHand({required HandNumber handNumber}) async {
    if (finished) throw GameFinishedException();
    _deletedHands.add((
      handNumber: handNumber,
      hand: _hands[handNumber.number],
    ));
    _hands.removeAt(handNumber.number);
    await _save();
  }

  Future<void> restoreLastHand() async {
    if (finished) throw GameFinishedException();
    if (!canRestore) return;
    final HandNumber handNumber = _deletedHands.last.handNumber;
    final Hand hand = _deletedHands.last.hand;
    _hands.insert(handNumber.number, hand);
    _deletedHands.removeLast();
    await _save();
  }

  Position playerPosition(Player player) => player.currentPosition(
    handNumber: currentHandNumber,
    withExtraPlayer: withExtraPlayer,
  );

  bool isPlaying(Player player) => playerPosition(player) != Position.extra;

  HandScores handScores() {
    List<PlayerScores> playerScoresList = [];
    List<PlayerScores> playerTotalScoresList = [
      Map.fromIterables(players, List.filled(players.length, 0)),
    ];

    for (final hand in _hands) {
      PlayerScores playerScores = Map.fromIterables(
        players,
        List.filled(players.length, 0),
      );
      switch (hand.endKind) {
        case HandEndKind.draw:
          ;
        case HandEndKind.selfDraw:
          playerScores.updateAll((player, score) {
            if (isPlaying(player)) {
              if (player == hand.winner!) {
                score = (hand.value! + 8) * 3;
              } else {
                score = -hand.value! - 8;
              }
            }

            return score;
          });
        case HandEndKind.offDiscard:
          playerScores.updateAll((player, score) {
            if (isPlaying(player)) {
              if (player == hand.winner!) {
                score = hand.value! + 8 * 3;
              } else if (player == hand.giver!) {
                score = -hand.value! - 8;
              } else {
                score = -8;
              }
            }

            return score;
          });
      }

      playerScoresList.add(playerScores);
      playerTotalScoresList.add(
        playerScores + playerTotalScoresList.lastOrNull,
      );
    }

    return (partial: playerScoresList, total: playerTotalScoresList);
  }

  PlayerScores playerTotalScores() {
    final (partial: _, total: playerTotalScoresList) = handScores();
    return playerTotalScoresList.last;
  }

  factory Game({
    required Set<Player> players,
    DateTime? startTime,
    DateTime? endTime,
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
      players: players,
      startTime: startTime ?? DateTime.timestamp(),
      endTime: endTime,
    );
  }

  factory Game.fromJson(Map<String, Object?> json) {
    if (!json.containsKey('endTime')) json['endTime'] = null;

    if (json case {
      'players': final List<Object?> jsonPlayers,
      'startTime': final String startTimeString,
      'endTime': final String? endTimeString,
      'hands': final List<Object?> jsonHands,
    }) {
      final Set<Player> players =
          jsonPlayers
              .map((json) => Player.fromJson(json as Map<String, Object?>))
              .toSet();
      final Game game = Game(
        players: players,
        startTime: DateTime.parse(startTimeString),
      );
      final DateTime? endTime = DateTime.tryParse(endTimeString ?? '');

      for (final hand in jsonHands) {
        if (hand is Map<String, Object?>) {
          if (!hand.containsKey('endTime')) hand['endTime'] = null;

          switch (hand) {
            case {'endTime': final String? endTimeString, 'endKind': 'draw'}:
              game.addHand(
                hand: Hand.draw(
                  endTime:
                      DateTime.tryParse(endTimeString ?? '') ?? game.startTime,
                ),
              );
            case {
              'endTime': final String? endTimeString,
              'endKind': 'selfDraw',
              'value': final int value,
              'winner': final int winnerInitialPosition,
            }:
              game.addHand(
                hand: Hand.selfDraw(
                  endTime:
                      DateTime.tryParse(endTimeString ?? '') ?? game.startTime,
                  value: value,
                  winner: players.firstWhere(
                    (player) =>
                        player.initialPosition.index == winnerInitialPosition,
                  ),
                ),
              );
            case {
              'endTime': final String? endTimeString,
              'endKind': 'offDiscard',
              'value': final int value,
              'winner': final int winnerInitialPosition,
              'giver': final int giverInitialPosition,
            }:
              game.addHand(
                hand: Hand.offDiscard(
                  endTime:
                      DateTime.tryParse(endTimeString ?? '') ?? game.startTime,
                  value: value,
                  winner: players.firstWhere(
                    (player) =>
                        player.initialPosition.index == winnerInitialPosition,
                  ),
                  giver: players.firstWhere(
                    (player) =>
                        player.initialPosition.index == giverInitialPosition,
                  ),
                ),
              );
          }
        }
      }

      if (endTime != null) game.finish(newEndTime: endTime);
      return game;
    }

    throw FormatException('Could not deserialize Game, json=$json');
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'players': players.map((player) => player.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'finished': finished,
    'hands':
        hands
            .map(
              (hand) => {
                'endTime': hand.endTime.toIso8601String(),
                'endKind': hand.endKind,
                'value': hand.value,
                'winner': hand.winner?.initialPosition,
                'giver': hand.giver?.initialPosition,
              },
            )
            .toList(),
  };
}

class GameFinishedException implements Exception {
  GameFinishedException();

  @override
  String toString() {
    // TODO: implement toString
    return 'Game finished, cannot modify.';
  }
}

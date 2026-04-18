import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mcr_tracker/l10n/app_localizations.dart';

// The offset after the seat rotation each round (set of 4 hands)
const positionOffsets = {
  Position.east: [0, 1, 3, 2],
  Position.south: [0, 3, 1, 2],
  Position.west: [0, 1, 2, 3],
  Position.north: [0, 3, 2, 1],
};

enum Position implements Comparable {
  east,
  south,
  west,
  north,
  extra;

  String translatedString(BuildContext context) => switch (this) {
    Position.east => AppLocalizations.of(context)!.east,
    Position.south => AppLocalizations.of(context)!.south,
    Position.west => AppLocalizations.of(context)!.west,
    Position.north => AppLocalizations.of(context)!.north,
    Position.extra => AppLocalizations.of(context)!.extra,
  };

  String get character => switch (this) {
    Position.east => '東',
    Position.south => '南',
    Position.west => '西',
    Position.north => '北',
    Position.extra => '',
  };

  factory Position.fromJson(int inputIndex) => values[inputIndex];
  int toJson() => index;

  @override
  int compareTo(other) {
    return index.compareTo(other.index);
  }
}

enum HandEndKind {
  draw,
  selfDraw,
  offDiscard;

  String translatedString(BuildContext context) => switch (this) {
    HandEndKind.draw => AppLocalizations.of(context)!.draw,
    HandEndKind.selfDraw => AppLocalizations.of(context)!.self,
    HandEndKind.offDiscard => AppLocalizations.of(context)!.offDiscard,
  };

  factory HandEndKind.fromJson(String inputString) =>
      values.firstWhere((value) => value.name == inputString);
  String toJson() => name;
}

typedef PlayerScores = Map<Player, int>;
typedef HandScores = ({List<PlayerScores> partial, List<PlayerScores> total});

class Game {
  Game._internal({
    required this.players,
    required this.startTime,
    this.finished = false,
  });

  final DateTime startTime;
  final Set<Player> players;
  final List<Hand> _hands = [];
  bool finished;

  UnmodifiableListView<Player> get playersSorted =>
      UnmodifiableListView(players.sorted((a, b) => a.compareTo(b)));
  UnmodifiableListView<Hand> get hands => UnmodifiableListView(_hands);
  HandNumber get currentHandNumber => HandNumber(_hands.length);
  bool get withExtraPlayer => players.length > 4;

  void addHand(Hand hand) {
    _hands.add(hand);
  }

  void removeHand(Hand hand) {
    _hands.remove(hand);
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

  factory Game({required Set<Player> players, bool finished = false}) {
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
        'The players must have wind positions before the extra position.',
      );
    }

    return Game._internal(
      players: players,
      startTime: DateTime.timestamp(),
      finished: finished,
    );
  }

  factory Game.fromJson(Map<String, Object?> json) {
    if (json case {
      'players': final List<Object?> jsonPlayers,
      'startTime': final String startTime,
      'finished': final bool finished,
      'hands': final List<Object?> jsonHands,
    }) {
      final Set<Player> players =
          jsonPlayers
              .map((json) => Player.fromJson(json as Map<String, Object?>))
              .toSet();
      final Game game = Game._internal(
        players: players,
        startTime: DateTime.parse(startTime),
        finished: finished,
      );

      for (final hand in jsonHands) {
        switch (hand) {
          case {'endKind': 'draw'}:
            game.addHand(Hand.draw());
          case {
            'endKind': 'selfDraw',
            'value': final int value,
            'winner': final int winnerInitialPosition,
          }:
            game.addHand(
              Hand.selfDraw(
                value: value,
                winner: players.firstWhere(
                  (player) =>
                      player.initialPosition.index == winnerInitialPosition,
                ),
              ),
            );
          case {
            'endKind': 'offDiscard',
            'value': final int value,
            'winner': final int winnerInitialPosition,
            'giver': final int giverInitialPosition,
          }:
            game.addHand(
              Hand.offDiscard(
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

      return game;
    }

    throw FormatException('Could not deserialize Game, json=$json');
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'players': players.map((player) => player.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'finished': finished,
    'hands':
        hands
            .map(
              (hand) => {
                'endKind': hand.endKind,
                'value': hand.value,
                'winner': hand.winner?.initialPosition,
                'giver': hand.giver?.initialPosition,
              },
            )
            .toList(),
  };
}

extension on PlayerScores {
  PlayerScores operator +(PlayerScores? other) {
    if (other == null) return this;

    return map((player, score) {
      score += other[player] ?? 0;
      return MapEntry(player, score);
    });
  }
}

class Player implements Comparable {
  Player({required this.name, required this.initialPosition});

  final String name;
  Position initialPosition;

  Position currentPosition({
    required HandNumber handNumber,
    bool withExtraPlayer = false,
  }) {
    final int roundNumber = handNumber.roundNumber;
    final int currentIndex;

    if (!withExtraPlayer) {
      if (initialPosition != Position.extra) {
        // Get offset, with round modulo 4 to handle cases with over 4 rounds.
        final int offset = positionOffsets[initialPosition]![roundNumber % 4];

        // Get index of current wind by taking the initial wind index and adding the
        // hand number (wind rotation) and the offset due to seat rotation, modulo 4.
        currentIndex = (initialPosition.index - handNumber.number + offset) % 4;
      } else {
        throw ArgumentError(
          "initialPosition can only be extra if there's an extra player",
        );
      }
    } else {
      // We don't rotate seats with 5 players for the moment.
      // TODO: rotate seats (5 rounds?).

      // Get index of current wind by taking the initial wind index and adding the
      // hand number (wind rotation), modulo 5.
      currentIndex = (initialPosition.index - handNumber.number) % 5;
    }

    return Position.values[currentIndex];
  }

  factory Player.fromJson(Map<String, Object?> json) {
    if (json case {
      'name': final String name,
      'initialPosition': final int initialPosition,
    }) {
      return Player(
        name: name,
        initialPosition: Position.fromJson(initialPosition),
      );
    }

    throw FormatException('Could not deserialize Player, json=$json');
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'initialPosition': initialPosition,
  };

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => Object.hash(name, initialPosition);

  @override
  bool operator ==(Object other) {
    return other is Player &&
        name == other.name &&
        initialPosition == other.initialPosition;
  }

  @override
  int compareTo(other) {
    return initialPosition.compareTo(other.initialPosition);
  }
}

class Hand {
  final HandEndKind endKind;
  final int? value;
  final Player? winner;
  final Player? giver;

  Hand.draw()
    : endKind = HandEndKind.draw,
      value = null,
      winner = null,
      giver = null;
  Hand.selfDraw({required int this.value, required Player this.winner})
    : endKind = HandEndKind.selfDraw,
      giver = null;
  Hand.offDiscard({
    required int this.value,
    required Player this.winner,
    required Player this.giver,
  }) : endKind = HandEndKind.offDiscard;
}

class HandNumber {
  HandNumber(this.number, {this.playerNumber = 4});

  final int number;
  final int playerNumber;

  int get roundNumber => number ~/ playerNumber;
  int get roundHandNumber => number % playerNumber;
  Position get position => Position.values[roundNumber];
}

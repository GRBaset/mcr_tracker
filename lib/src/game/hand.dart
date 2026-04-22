import 'package:flutter/material.dart';
import 'package:mcr_tracker/l10n/app_localizations.dart';

import 'scores.dart';
import 'player.dart';
import 'types.dart';

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

class HandEnd implements ScoreEntry {
  HandEnd._internal({
    required this.endTime,
    required this.endKind,
    this.value,
    this.winner,
    this.giver,
  });

  final DateTime endTime;
  final HandEndKind endKind;
  final int? value;
  final Player? winner;
  final Player? giver;

  factory HandEnd.draw({DateTime? endTime}) => HandEnd._internal(
    endTime: endTime ?? DateTime.timestamp(),
    endKind: HandEndKind.draw,
  );

  factory HandEnd.selfDraw({
    DateTime? endTime,
    required int value,
    required Player winner,
  }) => HandEnd._internal(
    endTime: endTime ?? DateTime.timestamp(),
    endKind: HandEndKind.selfDraw,
    value: value,
    winner: winner,
  );

  factory HandEnd.offDiscard({
    DateTime? endTime,
    required int value,
    required Player winner,
    required Player giver,
  }) => HandEnd._internal(
    endTime: endTime ?? DateTime.timestamp(),
    endKind: HandEndKind.offDiscard,
    value: value,
    winner: winner,
    giver: giver,
  );

  factory HandEnd.fromJson(
    Map<String, Object?> json, {
    required Set<Player> players,
    DateTime? defaultTime,
  }) => switch (json) {
    {'endTime': final String? endTimeString, 'endKind': 'draw'} => HandEnd.draw(
      endTime: DateTime.tryParse(endTimeString ?? '') ?? defaultTime,
    ),
    {
      'endTime': final String? endTimeString,
      'endKind': 'selfDraw',
      'value': final int value,
      'winner': final int winnerInitialPosition,
    } =>
      HandEnd.selfDraw(
        endTime: DateTime.tryParse(endTimeString ?? '') ?? defaultTime,
        value: value,
        winner: players.firstWhere(
          (player) => player.initialPosition.index == winnerInitialPosition,
        ),
      ),
    {
      'endTime': final String? endTimeString,
      'endKind': 'offDiscard',
      'value': final int value,
      'winner': final int winnerInitialPosition,
      'giver': final int giverInitialPosition,
    } =>
      HandEnd.offDiscard(
        endTime: DateTime.tryParse(endTimeString ?? '') ?? defaultTime,
        value: value,
        winner: players.firstWhere(
          (player) => player.initialPosition.index == winnerInitialPosition,
        ),
        giver: players.firstWhere(
          (player) => player.initialPosition.index == giverInitialPosition,
        ),
      ),
    _ => throw FormatException('Could not deserialize Hand, json=$json'),
  };

  Map<String, Object?> toJson() => <String, Object?>{
    'endTime': endTime.toIso8601String(),
    'endKind': endKind,
    'value': value,
    'winner': winner?.initialPosition,
    'giver': giver?.initialPosition,
  };

  @override
  PlayerScores playerScores(Iterable<Player> playersPlaying) {
    return switch (endKind) {
      HandEndKind.draw => PlayerScores.zero(playersPlaying),
      HandEndKind.selfDraw => PlayerScores(
        Map.fromEntries(
          playersPlaying.map((player) {
            final int score;
            if (player == winner!) {
              score = (value! + 8) * 3;
            } else {
              score = -value! - 8;
            }

            return MapEntry(player, score);
          }),
        ),
      ),
      HandEndKind.offDiscard => PlayerScores(
        Map.fromEntries(
          playersPlaying.map((player) {
            final int score;
            if (player == winner!) {
              score = value! + 8 * 3;
            } else if (player == giver!) {
              score = -value! - 8;
            } else {
              score = -8;
            }

            return MapEntry(player, score);
          }),
        ),
      ),
    };
  }
}

class HandNumber implements Comparable {
  HandNumber(this.number, {this.handsPerRound = 4});

  final int number;
  final int handsPerRound;

  int get roundNumber => number ~/ handsPerRound;
  int get roundHandNumber => number % handsPerRound;
  Position get position => Position.values[roundNumber];

  @override
  int compareTo(other) {
    return number.compareTo(other.number);
  }

  @override
  String toString() {
    return number.toString();
  }

  String toJson() {
    return toString();
  }

  HandNumber operator +(int other) {
    return HandNumber(number + other);
  }

  HandNumber operator -(int other) {
    return HandNumber(number - other);
  }

  @override
  bool operator ==(Object other) {
    return other is HandNumber && number == other.number;
  }

  @override
  int get hashCode => number.hashCode;
}

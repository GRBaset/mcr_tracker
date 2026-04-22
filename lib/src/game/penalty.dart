import 'package:flutter/material.dart';
import 'package:mcr_tracker/l10n/app_localizations.dart';
import 'package:mcr_tracker/src/game/scores.dart';

import 'player.dart';

enum PenaltyKind {
  pointPenalty,
  deadHand,
  warning;

  String translatedString(BuildContext context) => switch (this) {
    PenaltyKind.pointPenalty => AppLocalizations.of(context)!.pointPenalty,
    PenaltyKind.deadHand => AppLocalizations.of(context)!.deadHand,
    PenaltyKind.warning => AppLocalizations.of(context)!.warning,
  };

  factory PenaltyKind.fromJson(String inputString) =>
      values.firstWhere((value) => value.name == inputString);
  String toJson() => name;
}

enum PenaltyReason {
  invalidHand,
  notEnoughPoints,
  winningTileNotTaken,
  repeatedFouls,
  lateArrival,
  obstruction,
  other;

  String translatedString(BuildContext context) => switch (this) {
    PenaltyReason.repeatedFouls => AppLocalizations.of(context)!.repeatedFouls,
    PenaltyReason.invalidHand => AppLocalizations.of(context)!.invalidHand,
    PenaltyReason.notEnoughPoints =>
      AppLocalizations.of(context)!.notEnoughPoints,
    PenaltyReason.winningTileNotTaken =>
      AppLocalizations.of(context)!.winningTileNotTaken,
    PenaltyReason.lateArrival => AppLocalizations.of(context)!.lateArrival,
    PenaltyReason.obstruction => AppLocalizations.of(context)!.obstruction,
    PenaltyReason.other => AppLocalizations.of(context)!.other,
  };

  PenaltyPoints? points() => switch (this) {
    PenaltyReason.invalidHand => (deduced: 0, perOpponent: 20),
    PenaltyReason.notEnoughPoints => (deduced: 0, perOpponent: 10),
    PenaltyReason.winningTileNotTaken => (deduced: 10, perOpponent: 0),
    _ => null,
  };

  factory PenaltyReason.fromJson(String inputString) =>
      values.firstWhere((value) => value.name == inputString);
  String toJson() => name;
}

typedef PenaltyPoints = ({int deduced, int perOpponent});

class Penalty implements ScoreEntry {
  Penalty._internal({
    required this.time,
    required this.player,
    required this.kind,
    required this.reason,
    required this.points,
    this.description,
  });

  final DateTime time;
  final Player player;
  final PenaltyKind kind;
  final PenaltyReason reason;
  final PenaltyPoints points;
  final String? description;

  factory Penalty({
    DateTime? time,
    required Player player,
    required PenaltyKind kind,
    PenaltyReason reason = PenaltyReason.other,
    PenaltyPoints? penaltyPoints,
    String? description,
  }) {
    final PenaltyPoints points =
        penaltyPoints ?? reason.points() ?? (deduced: 0, perOpponent: 0);
    return Penalty._internal(
      time: time ?? DateTime.timestamp(),
      player: player,
      kind: kind,
      reason: reason,
      points: points,
      description: description,
    );
  }

  factory Penalty.fromJson(
    Map<String, Object?> json, {
    required Set<Player> players,
  }) {
    if (json case {
      'time': final String timeString,
      'player': final int playerInitialPosition,
      'kind': final String kind,
      'reason': final String reason,
      'points': final Map<String, Object?> pointsJson,
      'description': final String? description,
    }) {
      if (pointsJson case {
        'deduced': final int deduced,
        'perOpponent': final int perOpponent,
      }) {
        final PenaltyPoints points = (
          deduced: deduced,
          perOpponent: perOpponent,
        );

        return Penalty(
          time: DateTime.tryParse(timeString),
          player: players.firstWhere(
            (player) => player.initialPosition.index == playerInitialPosition,
          ),
          kind: PenaltyKind.fromJson(kind),
          reason: PenaltyReason.fromJson(reason),
          penaltyPoints: points,
          description: description,
        );
      }
    }

    throw FormatException('Could not deserialize Penalty, json=$json');
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'time': time.toIso8601String(),
    'player': player.initialPosition,
    'kind': kind,
    'reason': reason,
    'points': {'deduced': points.deduced, 'perOpponent': points.perOpponent},
    'description': description,
  };

  @override
  PlayerScores playerScores(Iterable<Player> playersPlaying) => PlayerScores(
    Map.fromEntries(
      playersPlaying.map((currentPlayer) {
        final int score;
        if (currentPlayer == player) {
          score = -points.deduced - 3 * points.perOpponent;
        } else {
          score = points.perOpponent;
        }

        return MapEntry(currentPlayer, score);
      }),
    ),
  );
}

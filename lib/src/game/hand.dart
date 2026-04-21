import 'player.dart';
import 'types.dart';

class Hand {
  Hand._internal({
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

  factory Hand.draw({DateTime? endTime}) => Hand._internal(
    endTime: endTime ?? DateTime.timestamp(),
    endKind: HandEndKind.draw,
  );

  factory Hand.selfDraw({
    DateTime? endTime,
    required int value,
    required Player winner,
  }) => Hand._internal(
    endTime: endTime ?? DateTime.timestamp(),
    endKind: HandEndKind.selfDraw,
    value: value,
    winner: winner,
  );

  factory Hand.offDiscard({
    DateTime? endTime,
    required int value,
    required Player winner,
    required Player giver,
  }) => Hand._internal(
    endTime: endTime ?? DateTime.timestamp(),
    endKind: HandEndKind.offDiscard,
    value: value,
    winner: winner,
    giver: giver,
  );
}

class HandNumber {
  HandNumber(this.number, {this.playerNumber = 4});

  final int number;
  final int playerNumber;

  int get roundNumber => number ~/ playerNumber;
  int get roundHandNumber => number % playerNumber;
  Position get position => Position.values[roundNumber];
}

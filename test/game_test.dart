import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mcr_tracker/src/game.dart';

const String testGame = './test/test_data/test_game.json';

void main() {
  group('Hand tests', () {
    test('Drawn hand', () {
      final hand = Hand.draw();
      expect(hand.endKind, HandEndKind.draw);
      expect(hand.value, null);
    });

    test('Self-drawn hand', () {
      final hand = Hand.selfDraw(
        value: 8,
        winner: Player(name: "test", initialPosition: Position.east),
      );
      expect(hand.endKind, HandEndKind.selfDraw);
      expect(hand.value, 8);
    });
  });

  group('Player tests', () {
    test('Player position test', () {
      final eastPlayer = Player(name: 'test', initialPosition: Position.east);
      final southPlayer = Player(name: 'test', initialPosition: Position.south);
      final extraPlayer = Player(name: 'test', initialPosition: Position.extra);
      for (int i = 0; i < 16; i++) {
        print(southPlayer.currentPosition(handNumber: HandNumber(i)));
      }
      expect(
        eastPlayer.currentPosition(handNumber: HandNumber(15)),
        Position.north,
      );
      expect(
        southPlayer.currentPosition(handNumber: HandNumber(15)),
        Position.east,
      );
    });

    test('Extra player position test', () {
      final extraPlayer = Player(name: 'test', initialPosition: Position.extra);
      for (int i = 0; i < 16; i++) {
        print(
          extraPlayer.currentPosition(
            handNumber: HandNumber(i),
            withExtraPlayer: true,
          ),
        );
      }
      expect(
        extraPlayer.currentPosition(
          handNumber: HandNumber(15),
          withExtraPlayer: true,
        ),
        Position.extra,
      );
      expect(
        extraPlayer.currentPosition(
          handNumber: HandNumber(6),
          withExtraPlayer: true,
        ),
        Position.north,
      );
    });
  });

  group('Game tests', () {
    test('Player scores', () {
      final players = [
        Player(name: '1', initialPosition: Position.east),
        Player(name: '2', initialPosition: Position.south),
        Player(name: '3', initialPosition: Position.west),
        Player(name: '4', initialPosition: Position.north),
      ];
      final game = Game(players: players.toSet());
      game.addHand(Hand.selfDraw(value: 8, winner: players[0]));
      expect(game.handScores().partial[0][players[0]], 48);

      game.addHand(
        Hand.offDiscard(value: 16, winner: players[2], giver: players[0]),
      );
      print(game.handScores());
      expect(game.handScores().total[1][players[0]], 24);
    });

    test('toJson', () async {
      final List<Player> players = [
        Player(name: '1', initialPosition: Position.east),
        Player(name: '2', initialPosition: Position.south),
        Player(name: '3', initialPosition: Position.west),
        Player(name: '4', initialPosition: Position.north),
      ];
      final Game game = Game(players: players.toSet());
      game.addHand(Hand.draw());
      game.addHand(Hand.selfDraw(value: 8, winner: players[0]));
      game.addHand(
        Hand.offDiscard(value: 16, winner: players[2], giver: players[0]),
      );

      final String json = await File(testGame).readAsString();

      //expect(game.toJson(), jsonDecode(json));
      print(jsonEncode(game.toJson()));
    });

    test('fromJson', () async {
      final players = [
        Player(name: '1', initialPosition: Position.east),
        Player(name: '2', initialPosition: Position.south),
        Player(name: '3', initialPosition: Position.west),
        Player(name: '4', initialPosition: Position.north),
      ];
      final game = Game(players: players.toSet());
      game.addHand(Hand.draw());
      game.addHand(Hand.selfDraw(value: 8, winner: players[0]));
      game.addHand(
        Hand.offDiscard(value: 16, winner: players[2], giver: players[0]),
      );

      final String json = await File(testGame).readAsString();

      print(game.toJson());
      print(Game.fromJson(jsonDecode(json)).toJson());

      expect(Game.fromJson(jsonDecode(json)), game);
    });
  });
}

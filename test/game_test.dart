import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:mcr_tracker/src/game/game.dart';
import 'package:mcr_tracker/src/game_storage.dart';

@GenerateNiceMocks([MockSpec<GameStorage>()])
import 'game_test.mocks.dart';

const String testGameV1 = './test/test_data/test_game_v1.json';
const String testGameV2 = './test/test_data/test_game_v2.json';
const String testGameV3 = './test/test_data/test_game_v3.json';

void main() {
  group('Hand tests', () {
    test('Drawn hand', () {
      final hand = HandEnd.draw();
      expect(hand.endKind, HandEndKind.draw);
      expect(hand.value, null);
    });

    test('Self-drawn hand', () {
      final hand = HandEnd.selfDraw(
        value: 8,
        winner: Player(name: "test", initialPosition: Position.east),
      );
      expect(hand.endKind, HandEndKind.selfDraw);
      expect(hand.value, 8);
    });
  });

  group('Penalty tests', () {
    test('toJson', () {
      final penalty = Penalty(
        player: Player(name: "test", initialPosition: Position.east),
        kind: PenaltyKind.pointPenalty,
      );
      print(jsonEncode(penalty.toJson()));
    });
    test('fromJson', () {
      final json =
          '{"time":"2026-04-21T20:23:07.627602Z","player":0,"kind":"pointPenalty","reason":"other","points":{"deduced":10,"perOpponent":0},"description":null}';

      print(
        Penalty.fromJson(
          jsonDecode(json),
          players: {Player(name: "test", initialPosition: Position.east)},
        ).toJson(),
      );
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
      game.addHand(hand: HandEnd.selfDraw(value: 8, winner: players[0]));
      expect(game.gameScores()[HandNumber(0)]!.endScores![players[0]], 48);

      game.addHand(
        hand: HandEnd.offDiscard(
          value: 16,
          winner: players[2],
          giver: players[0],
        ),
      );
      print(game.gameScores());
      expect(game.gameScores()[HandNumber(1)]!.endScores![players[0]], 24);
    });

    test('toJson', () async {
      final List<Player> players = [
        Player(name: '1', initialPosition: Position.east),
        Player(name: '2', initialPosition: Position.south),
        Player(name: '3', initialPosition: Position.west),
        Player(name: '4', initialPosition: Position.north),
      ];
      final Game game = Game(
        players: players.toSet(),
        storage: MockGameStorage(),
      );
      game.addHand(hand: HandEnd.draw());
      game.addHand(hand: HandEnd.selfDraw(value: 8, winner: players[0]));
      game.addHand(
        hand: HandEnd.offDiscard(
          value: 16,
          winner: players[2],
          giver: players[0],
        ),
      );
      game.addPenalty(
        penalty: Penalty(player: players[1], kind: PenaltyKind.pointPenalty),
      );

      final String json = await File(testGameV1).readAsString();

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
      final game = Game(
        players: players.toSet(),
        startTime: DateTime.fromMillisecondsSinceEpoch(0),
        storage: MockGameStorage(),
      );
      game.addHand(hand: HandEnd.draw(endTime: game.startTime));
      game.addHand(
        hand: HandEnd.selfDraw(
          endTime: game.startTime,
          value: 8,
          winner: players[0],
        ),
      );
      game.addHand(
        hand: HandEnd.offDiscard(
          endTime: game.startTime,
          value: 16,
          winner: players[2],
          giver: players[0],
        ),
      );
      game.addPenalty(
        penalty: Penalty(player: players[1], kind: PenaltyKind.pointPenalty),
      );

      final String json = await File(testGameV1).readAsString();
      final String json2 = await File(testGameV2).readAsString();
      final String json3 = await File(testGameV3).readAsString();

      print(game.toJson());
      print(
        Game.fromJson(jsonDecode(json), storage: MockGameStorage()).toJson(),
      );
      print(
        Game.fromJson(jsonDecode(json2), storage: MockGameStorage()).toJson(),
      );
      print(
        Game.fromJson(jsonDecode(json3), storage: MockGameStorage()).toJson(),
      );

      // expect(Game.fromJson(jsonDecode(json)), game);
    });
  });
}

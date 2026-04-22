import 'game.dart';

abstract class ScoreEntry {
  PlayerScores playerScores(Iterable<Player> playersPlaying);
}

extension type GameScores(Map<HandNumber, HandScores> gameScores)
    implements Map<HandNumber, HandScores> {
  PlayerScores sum(Iterable<Player> players) => gameScores.values.fold(
    PlayerScores.zero(players),
    (a, b) => a + b.sum(players),
  );
}

class HandScores {
  HandScores({this.endScores, this.penaltyScores});

  final PlayerScores? endScores;
  final List<PlayerScores>? penaltyScores;

  PlayerScores sum(Iterable<Player> players) {
    final PlayerScores zeroScores = PlayerScores.zero(players);
    return (endScores ?? zeroScores) +
        penaltyScores?.fold(zeroScores, (a, b) => a ?? zeroScores + b);
  }
}

extension type PlayerScores(Map<Player, int> playerScores)
    implements Map<Player, int> {
  factory PlayerScores.zero(Iterable<Player> players) =>
      PlayerScores(Map.fromIterables(players, List.filled(players.length, 0)));

  PlayerScores operator +(PlayerScores? other) {
    if (other == null) return this;

    return PlayerScores(
      map((player, score) {
        score += other[player] ?? 0;
        return MapEntry(player, score);
      }),
    );
  }
}

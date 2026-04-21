import 'hand.dart';
import 'types.dart';

// The offset after the seat rotation each round (set of 4 hands)
const positionOffsets = {
  Position.east: [0, 1, 3, 2],
  Position.south: [0, 3, 1, 2],
  Position.west: [0, 1, 2, 3],
  Position.north: [0, 3, 2, 1],
};

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

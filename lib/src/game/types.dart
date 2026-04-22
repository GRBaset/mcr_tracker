import 'package:flutter/material.dart';
import 'package:mcr_tracker/l10n/app_localizations.dart';

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

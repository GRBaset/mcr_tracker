import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

String getLocalizedWindTurn(BuildContext context, String turn) {
  if (turn == turnNames[0]) {
    return '${AppLocalizations.of(context)!.east} 1';
  } else if (turn == turnNames[1]) {
    return '${AppLocalizations.of(context)!.east} 2';
  } else if (turn == turnNames[2]) {
    return '${AppLocalizations.of(context)!.east} 3';
  } else if (turn == turnNames[3]) {
    return '${AppLocalizations.of(context)!.east} 4';
  } else if (turn == turnNames[4]) {
    return '${AppLocalizations.of(context)!.south} 1';
  } else if (turn == turnNames[5]) {
    return '${AppLocalizations.of(context)!.south} 2';
  } else if (turn == turnNames[6]) {
    return '${AppLocalizations.of(context)!.south} 3';
  } else if (turn == turnNames[7]) {
    return '${AppLocalizations.of(context)!.south} 4';
  } else if (turn == turnNames[8]) {
    return '${AppLocalizations.of(context)!.west} 1';
  } else if (turn == turnNames[9]) {
    return '${AppLocalizations.of(context)!.west} 2';
  } else if (turn == turnNames[10]) {
    return '${AppLocalizations.of(context)!.west} 3';
  } else if (turn == turnNames[11]) {
    return '${AppLocalizations.of(context)!.west} 4';
  } else if (turn == turnNames[12]) {
    return '${AppLocalizations.of(context)!.north} 1';
  } else if (turn == turnNames[13]) {
    return '${AppLocalizations.of(context)!.north} 2';
  } else if (turn == turnNames[14]) {
    return '${AppLocalizations.of(context)!.north} 3';
  } else if (turn == turnNames[15]) {
    return '${AppLocalizations.of(context)!.north} 4';
  } else if (turn == turnNames[16]) {
    return AppLocalizations.of(context)!.finished;
  }
  return turn;
}

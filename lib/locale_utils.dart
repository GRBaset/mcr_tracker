

import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

String getLocalizedWindTurn(BuildContext context, String turn) {
  if (turn == turnNames[0]) {
    return AppLocalizations.of(context)!.east1;
  } else if (turn == turnNames[1]) {
    return AppLocalizations.of(context)!.east2;
  } else if (turn == turnNames[2]) {
    return AppLocalizations.of(context)!.east3;
  } else if (turn == turnNames[3]) {
    return AppLocalizations.of(context)!.east4;
  } else if (turn == turnNames[4]) {
    return AppLocalizations.of(context)!.south1;
  } else if (turn == turnNames[5]) {
    return AppLocalizations.of(context)!.south2;
  } else if (turn == turnNames[6]) {
    return AppLocalizations.of(context)!.south3;
  } else if (turn == turnNames[7]) {
    return AppLocalizations.of(context)!.south4;
  } else if (turn == turnNames[8]) {
    return AppLocalizations.of(context)!.west1;
  } else if (turn == turnNames[9]) {
    return AppLocalizations.of(context)!.west2;
  } else if (turn == turnNames[10]) {
    return AppLocalizations.of(context)!.west3;
  } else if (turn == turnNames[11]) {
    return AppLocalizations.of(context)!.west4;
  } else if (turn == turnNames[12]) {
    return AppLocalizations.of(context)!.north1;
  } else if (turn == turnNames[13]) {
    return AppLocalizations.of(context)!.north2;
  } else if (turn == turnNames[14]) {
    return AppLocalizations.of(context)!.north3;
  } else if (turn == turnNames[15]) {
    return AppLocalizations.of(context)!.north4;
  } else if (turn == turnNames[16]) {
    return AppLocalizations.of(context)!.finished;
  }
  return turn;
}
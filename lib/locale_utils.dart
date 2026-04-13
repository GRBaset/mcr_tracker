import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

String getLocalizedWindTurn(BuildContext context, String hand) {
  if (hand == handNames[0]) {
    return '${AppLocalizations.of(context)!.east} 1';
  } else if (hand == handNames[1]) {
    return '${AppLocalizations.of(context)!.east} 2';
  } else if (hand == handNames[2]) {
    return '${AppLocalizations.of(context)!.east} 3';
  } else if (hand == handNames[3]) {
    return '${AppLocalizations.of(context)!.east} 4';
  } else if (hand == handNames[4]) {
    return '${AppLocalizations.of(context)!.south} 1';
  } else if (hand == handNames[5]) {
    return '${AppLocalizations.of(context)!.south} 2';
  } else if (hand == handNames[6]) {
    return '${AppLocalizations.of(context)!.south} 3';
  } else if (hand == handNames[7]) {
    return '${AppLocalizations.of(context)!.south} 4';
  } else if (hand == handNames[8]) {
    return '${AppLocalizations.of(context)!.west} 1';
  } else if (hand == handNames[9]) {
    return '${AppLocalizations.of(context)!.west} 2';
  } else if (hand == handNames[10]) {
    return '${AppLocalizations.of(context)!.west} 3';
  } else if (hand == handNames[11]) {
    return '${AppLocalizations.of(context)!.west} 4';
  } else if (hand == handNames[12]) {
    return '${AppLocalizations.of(context)!.north} 1';
  } else if (hand == handNames[13]) {
    return '${AppLocalizations.of(context)!.north} 2';
  } else if (hand == handNames[14]) {
    return '${AppLocalizations.of(context)!.north} 3';
  } else if (hand == handNames[15]) {
    return '${AppLocalizations.of(context)!.north} 4';
  } else if (hand == handNames[16]) {
    return AppLocalizations.of(context)!.finished;
  }
  return hand;
}

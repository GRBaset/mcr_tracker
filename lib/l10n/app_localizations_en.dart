// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get game => 'Game';

  @override
  String positionPlayer(String position) {
    return '$position player';
  }

  @override
  String get east => 'East';

  @override
  String get west => 'West';

  @override
  String get south => 'South';

  @override
  String get north => 'North';

  @override
  String get extra => 'Extra';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get viewButton => 'VIEW';

  @override
  String get deleteButton => 'DELETE';

  @override
  String get cancelButton => 'CANCEL';

  @override
  String get deleteQuestion => 'Delete game?';

  @override
  String get deleteDialog =>
      'Are you absolutely sure you want to delete this game? This action is irreversible.';

  @override
  String get required => 'Required';

  @override
  String get startGame => 'Start game';

  @override
  String get finished => 'Finished';

  @override
  String get loading => 'Loading...';

  @override
  String get total => 'Total';

  @override
  String get scoreSheet => 'Game Score Sheet';

  @override
  String get score => 'Score';

  @override
  String get hand => 'Hand';

  @override
  String get deleteLastHand => 'Delete last hand';

  @override
  String get handEnd => 'Hand end';

  @override
  String get handValue => 'Hand value';

  @override
  String get value => 'Value';

  @override
  String get winner => 'Winner';

  @override
  String get giver => 'Giver';

  @override
  String get moreThanEight => 'Needs to be higher than 8';

  @override
  String get addHand => 'Add hand';

  @override
  String get draw => 'Draw';

  @override
  String get self => 'Self-drawn';

  @override
  String get offDiscard => 'Off discard';
}

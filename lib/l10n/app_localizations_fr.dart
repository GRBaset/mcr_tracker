// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get game => 'Partie';

  @override
  String positionPlayer(String position) {
    return 'Joueur/euse $position';
  }

  @override
  String get east => 'Est';

  @override
  String get west => 'Ouest';

  @override
  String get south => 'Sud';

  @override
  String get north => 'Nord';

  @override
  String get extra => 'Supplémentaire';

  @override
  String get continueButton => 'CONTINUER';

  @override
  String get viewButton => 'VOIR';

  @override
  String get deleteButton => 'SUPPRIMER';

  @override
  String get cancelButton => 'ANNULER';

  @override
  String get deleteQuestion => 'Supprimer partie?';

  @override
  String get deleteDialog =>
      'Êtes-vous absolument certain de vouler supprimer ce partie? Cette action est irréversible.';

  @override
  String get required => 'Requis';

  @override
  String get startGame => 'Commencer la partie';

  @override
  String get finished => 'Finie';

  @override
  String get loading => 'Chargement en cours...';

  @override
  String get total => 'Total';

  @override
  String get scoreSheet => 'Feuille de scores';

  @override
  String get score => 'Score';

  @override
  String get round => 'Manche';

  @override
  String get deleteLastHand => 'Supprimer la dernière manche';

  @override
  String get handEnd => 'Fin de manche';

  @override
  String get handValue => 'Valeur de la main';

  @override
  String get winner => 'Gagnant';

  @override
  String get giver => 'Donneur';

  @override
  String get moreThanEight => 'Doit être supérieur à 8';

  @override
  String get addHand => 'Ajouter la manche';

  @override
  String get draw => 'Manche nulle';

  @override
  String get self => 'Tiré soi-même';

  @override
  String get offDiscard => 'Sur défausse';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get game => 'Partida';

  @override
  String positionPlayer(String position) {
    return 'Jugador(a) $position';
  }

  @override
  String get east => 'Este';

  @override
  String get west => 'Oeste';

  @override
  String get south => 'Sur';

  @override
  String get north => 'Norte';

  @override
  String get extra => 'Extra';

  @override
  String get continueButton => 'CONTINUAR';

  @override
  String get viewButton => 'VER';

  @override
  String get deleteButton => 'BORRAR';

  @override
  String get cancelButton => 'CANCELAR';

  @override
  String deleteQuestion(String object) {
    return '¿Borrar $object?';
  }

  @override
  String get deleteDialog =>
      '¿Estás absolutamente seguro de querer borrar esta partida? Esta acción es irreversible.';

  @override
  String get deleteHandDialog => '¿Quieres borrar la última mano?';

  @override
  String get required => 'Requerido';

  @override
  String get startGame => 'Comenzar la partida';

  @override
  String get newGame => 'Nueva partida';

  @override
  String get finished => 'Finalizada';

  @override
  String get loading => 'Cargando...';

  @override
  String get total => 'Total';

  @override
  String get scoreSheet => 'Hoja de puntuación';

  @override
  String get score => 'Puntos';

  @override
  String get hand => 'Mano';

  @override
  String get deleteLastHand => 'Borrar última mano';

  @override
  String get handEnd => 'Fin de mano';

  @override
  String get handValue => 'Valor de la mano';

  @override
  String get value => 'Valor';

  @override
  String get winner => 'Ganada por';

  @override
  String get giver => 'Descarte de';

  @override
  String get moreThanEight => 'Debe ser superior a 8';

  @override
  String get addHand => 'Añadir mano';

  @override
  String get draw => 'Empate';

  @override
  String get self => 'Del muro';

  @override
  String get offDiscard => 'De un descarte';
}

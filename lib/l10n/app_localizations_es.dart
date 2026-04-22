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
  String get player => 'Jugador(a)';

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
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get exportAll => 'Exportar todos';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get view => 'Ver';

  @override
  String get delete => 'Borrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String deleteQuestion(String object) {
    return '¿Borrar $object?';
  }

  @override
  String get deleteDialog =>
      '¿Estás absolutamente seguro de querer borrar esta partida? Esta acción es irreversible.';

  @override
  String deleteHandDialog(String position) {
    return '¿Quieres borrar la mano $position?';
  }

  @override
  String deletePenaltyDialog(String index, String position) {
    return 'Do you want to delete the $index penalty in the $position hand?';
  }

  @override
  String get required => 'Requerido';

  @override
  String get optional => 'Opcional';

  @override
  String get startGame => 'Comenzar la partida';

  @override
  String get newGame => 'Nueva partida';

  @override
  String get finish => 'Finalizar';

  @override
  String get resume => 'Resumir';

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
  String get last => 'Última';

  @override
  String get deleteLastHand => 'Borrar última mano';

  @override
  String get restoreLastHand => 'Restaurar última mano borrada';

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

  @override
  String get penalty => 'Penalización';

  @override
  String get penalize => 'Penalizar';

  @override
  String get penaltyKind => 'Tipo de penalización';

  @override
  String get penaltyReason => 'Motivo de penalización';

  @override
  String get deducedPoints => 'Puntos descontados';

  @override
  String get pointsPerOpponent => 'Puntos por oponente';

  @override
  String get description => 'Descripción';

  @override
  String get warning => 'Aviso';

  @override
  String get deadHand => 'Mano muerta';

  @override
  String get pointPenalty => 'Penalización de puntos';

  @override
  String get repeatedFouls => 'Faltas repetidas';

  @override
  String get invalidHand => 'Falso hu (mano inválida)';

  @override
  String get notEnoughPoints => 'Falso hu (puntos insuficientes)';

  @override
  String get winningTileNotTaken => 'Ficha ganadora no cogida';

  @override
  String get lateArrival => 'Impuntualidad';

  @override
  String get obstruction => 'Obstrucción';

  @override
  String get other => 'Otra';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @positionPlayer.
  ///
  /// In en, this message translates to:
  /// **'{position} player'**
  String positionPlayer(String position);

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get east;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get west;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get south;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get north;

  /// No description provided for @extra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get extra;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all'**
  String get exportAll;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {object}?'**
  String deleteQuestion(String object);

  /// No description provided for @deleteDialog.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this game? This action is irreversible.'**
  String get deleteDialog;

  /// No description provided for @deleteHandDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the {position} hand?'**
  String deleteHandDialog(String position);

  /// No description provided for @deletePenaltyDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the {index} penalty in the {position} hand?'**
  String deletePenaltyDialog(String index, String position);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @scoreSheet.
  ///
  /// In en, this message translates to:
  /// **'Game Score Sheet'**
  String get scoreSheet;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @hand.
  ///
  /// In en, this message translates to:
  /// **'Hand'**
  String get hand;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// No description provided for @deleteLastHand.
  ///
  /// In en, this message translates to:
  /// **'Delete last hand'**
  String get deleteLastHand;

  /// No description provided for @restoreLastHand.
  ///
  /// In en, this message translates to:
  /// **'Restore last deleted hand'**
  String get restoreLastHand;

  /// No description provided for @handEnd.
  ///
  /// In en, this message translates to:
  /// **'Hand end'**
  String get handEnd;

  /// No description provided for @handValue.
  ///
  /// In en, this message translates to:
  /// **'Hand value'**
  String get handValue;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @giver.
  ///
  /// In en, this message translates to:
  /// **'Giver'**
  String get giver;

  /// No description provided for @moreThanEight.
  ///
  /// In en, this message translates to:
  /// **'Needs to be higher than 8'**
  String get moreThanEight;

  /// No description provided for @addHand.
  ///
  /// In en, this message translates to:
  /// **'Add hand'**
  String get addHand;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @self.
  ///
  /// In en, this message translates to:
  /// **'Self-drawn'**
  String get self;

  /// No description provided for @offDiscard.
  ///
  /// In en, this message translates to:
  /// **'Off discard'**
  String get offDiscard;

  /// No description provided for @penalty.
  ///
  /// In en, this message translates to:
  /// **'Penalty'**
  String get penalty;

  /// No description provided for @penalize.
  ///
  /// In en, this message translates to:
  /// **'Penalize'**
  String get penalize;

  /// No description provided for @penaltyKind.
  ///
  /// In en, this message translates to:
  /// **'Penalty kind'**
  String get penaltyKind;

  /// No description provided for @penaltyReason.
  ///
  /// In en, this message translates to:
  /// **'Penalty reason'**
  String get penaltyReason;

  /// No description provided for @deducedPoints.
  ///
  /// In en, this message translates to:
  /// **'Deduced points'**
  String get deducedPoints;

  /// No description provided for @pointsPerOpponent.
  ///
  /// In en, this message translates to:
  /// **'Points per opponent'**
  String get pointsPerOpponent;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @deadHand.
  ///
  /// In en, this message translates to:
  /// **'Dead hand'**
  String get deadHand;

  /// No description provided for @pointPenalty.
  ///
  /// In en, this message translates to:
  /// **'Point penalty'**
  String get pointPenalty;

  /// No description provided for @repeatedFouls.
  ///
  /// In en, this message translates to:
  /// **'Repeated fouls'**
  String get repeatedFouls;

  /// No description provided for @invalidHand.
  ///
  /// In en, this message translates to:
  /// **'False hu (invalid hand)'**
  String get invalidHand;

  /// No description provided for @notEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'False hu (not enough points)'**
  String get notEnoughPoints;

  /// No description provided for @winningTileNotTaken.
  ///
  /// In en, this message translates to:
  /// **'Winning tile not taken'**
  String get winningTileNotTaken;

  /// No description provided for @lateArrival.
  ///
  /// In en, this message translates to:
  /// **'Late arrival'**
  String get lateArrival;

  /// No description provided for @obstruction.
  ///
  /// In en, this message translates to:
  /// **'Obstruction'**
  String get obstruction;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

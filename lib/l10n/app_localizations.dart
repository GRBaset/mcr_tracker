import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('fr'),
  ];

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @eastPlayer.
  ///
  /// In en, this message translates to:
  /// **'East player'**
  String get eastPlayer;

  /// No description provided for @westPlayer.
  ///
  /// In en, this message translates to:
  /// **'West player'**
  String get westPlayer;

  /// No description provided for @southPlayer.
  ///
  /// In en, this message translates to:
  /// **'South player'**
  String get southPlayer;

  /// No description provided for @northPlayer.
  ///
  /// In en, this message translates to:
  /// **'North player'**
  String get northPlayer;

  /// No description provided for @fifthPlayer.
  ///
  /// In en, this message translates to:
  /// **'5th player'**
  String get fifthPlayer;

  /// No description provided for @east1.
  ///
  /// In en, this message translates to:
  /// **'East 1'**
  String get east1;

  /// No description provided for @east2.
  ///
  /// In en, this message translates to:
  /// **'East 2'**
  String get east2;

  /// No description provided for @east3.
  ///
  /// In en, this message translates to:
  /// **'East 3'**
  String get east3;

  /// No description provided for @east4.
  ///
  /// In en, this message translates to:
  /// **'East 4'**
  String get east4;

  /// No description provided for @west1.
  ///
  /// In en, this message translates to:
  /// **'West 1'**
  String get west1;

  /// No description provided for @west2.
  ///
  /// In en, this message translates to:
  /// **'West 2'**
  String get west2;

  /// No description provided for @west3.
  ///
  /// In en, this message translates to:
  /// **'West 3'**
  String get west3;

  /// No description provided for @west4.
  ///
  /// In en, this message translates to:
  /// **'West 4'**
  String get west4;

  /// No description provided for @south1.
  ///
  /// In en, this message translates to:
  /// **'South 1'**
  String get south1;

  /// No description provided for @south2.
  ///
  /// In en, this message translates to:
  /// **'South 2'**
  String get south2;

  /// No description provided for @south3.
  ///
  /// In en, this message translates to:
  /// **'South 3'**
  String get south3;

  /// No description provided for @south4.
  ///
  /// In en, this message translates to:
  /// **'South 4'**
  String get south4;

  /// No description provided for @north1.
  ///
  /// In en, this message translates to:
  /// **'North 1'**
  String get north1;

  /// No description provided for @north2.
  ///
  /// In en, this message translates to:
  /// **'North 2'**
  String get north2;

  /// No description provided for @north3.
  ///
  /// In en, this message translates to:
  /// **'North 3'**
  String get north3;

  /// No description provided for @north4.
  ///
  /// In en, this message translates to:
  /// **'North 4'**
  String get north4;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @viewButton.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get viewButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelButton;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete game?'**
  String get deleteQuestion;

  /// No description provided for @deleteDialog.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this game? This action is irreversible.'**
  String get deleteDialog;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @scoreSheet.
  ///
  /// In en, this message translates to:
  /// **'Game Score Sheet'**
  String get scoreSheet;

  /// No description provided for @deleteLastTurn.
  ///
  /// In en, this message translates to:
  /// **'Delete last turn'**
  String get deleteLastTurn;

  /// No description provided for @turnEnd.
  ///
  /// In en, this message translates to:
  /// **'Turn end'**
  String get turnEnd;

  /// No description provided for @handValue.
  ///
  /// In en, this message translates to:
  /// **'Hand value'**
  String get handValue;

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

  /// No description provided for @addTurn.
  ///
  /// In en, this message translates to:
  /// **'Add turn'**
  String get addTurn;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @self.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get self;

  /// No description provided for @offDiscard.
  ///
  /// In en, this message translates to:
  /// **'Off discard'**
  String get offDiscard;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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

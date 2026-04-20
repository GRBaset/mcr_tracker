import 'dart:collection';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcr_tracker/src/game.dart';
import 'package:mcr_tracker/src/game_storage.dart';
import 'l10n/app_localizations.dart';

import 'gamesheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'MCR Score Tracker',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme:
                lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.purple),
          ),
          darkTheme: ThemeData(
            colorScheme:
                darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.purple,
                  brightness: Brightness.dark,
                ),
          ),
          home: const HomePage(title: 'MCR Score Tracker'),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, Widget> _gameCards = HashMap();
  final GameStorage _storage = GameStorage();

  @override
  void initState() {
    super.initState();

    _loadGames();
  }

  @override
  void didUpdateWidget(HomePage oldHomePage) {
    super.didUpdateWidget(oldHomePage);

    _loadGames();
  }

  void _loadGames() async {
    await _storage.loadAllGames();

    for (final String gameId in _storage.games.keys.sorted()) {
      Widget card = await _getNewCard(gameId);
      _gameCards[gameId] = card;
    }

    setState(() {});
  }

  String _getDesc(Game game) {
    String desc = "";
    final PlayerScores playerTotalScores = game.playerTotalScores();
    developer.log(playerTotalScores.toString());

    for (final Player player in game.playersSorted) {
      desc += "${player.name} ${playerTotalScores[player]}     ";
    }
    return desc;
  }

  Future<String> _createGame(Map<Position, String> playerNames) async {
    final Set<Player> players = {};
    playerNames.forEach((initialPosition, name) {
      if (name.isNotEmpty) {
        players.add(Player(name: name, initialPosition: initialPosition));
      }
    });

    final String gameId = await _storage.newGame(players: players);
    developer.log('Created game $gameId');

    return gameId;
  }

  Future<void> _deleteGameDialog(String gameId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(
              context,
            )!.deleteQuestion(AppLocalizations.of(context)!.game.toLowerCase()),
          ),
          content: Text(AppLocalizations.of(context)!.deleteDialog),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteGame(gameId);
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.deleteButton,
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancelButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGame(String gameId) async {
    _gameCards.remove(gameId);
    _storage.deleteGame(gameId: gameId);
    developer.log("Deleted game $gameId");
    setState(() {});
  }

  void _reloadGame(String gameId) async {
    developer.log("Reloading game $gameId");
    Widget newCard = await _getNewCard(gameId);
    _gameCards[gameId] = newCard;
    setState(() {});
  }

  Future<Widget> _getNewCard(String gameId) async {
    final Game game = await _storage.loadGame(gameId: gameId);

    if (!mounted) throw StateError('Context not mounted');
    return Card(
      key: Key(gameId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              '${AppLocalizations.of(context)!.game} ${_localizedHandPosition(game)}',
            ),
            subtitle: Text(_getDesc(game)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const SizedBox(width: 8),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.deleteButton,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  _deleteGameDialog(gameId);
                },
              ),
              const Spacer(),
              TextButton(
                child:
                    game.finished
                        ? Text(AppLocalizations.of(context)!.viewButton)
                        : Text(AppLocalizations.of(context)!.continueButton),
                onPressed: () => _navigateToGame(gameId),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToGame(String gameId) async {
    final Game game = await _storage.loadGame(gameId: gameId);
    final Route route =
        kDebugMode
            ? PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      GamePage(game: game),
            )
            : MaterialPageRoute(builder: (context) => GamePage(game: game));

    if (!mounted) throw StateError('Context not mounted');
    await Navigator.push(context, route);
    _reloadGame(gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(children: _gameCards.values.toList()),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newGameDialog,
        icon: const Icon(Icons.add),
        label: Text(
          AppLocalizations.of(context)!.newGame,
          style: TextStyle(
            fontSize: TextTheme.of(context).titleMedium?.fontSize,
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<dynamic> _newGameDialog() async {
    final Map<Position, String> playerNames = HashMap();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TextFormField(
                          onSaved: (value) {
                            playerNames[Position.east] = value!;
                          },
                          decoration: InputDecoration(
                            labelText:
                                "東 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.east)}",
                            prefixText: "東",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.required;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TextFormField(
                          onSaved: (value) {
                            playerNames[Position.south] = value!;
                          },
                          decoration: InputDecoration(
                            labelText:
                                "南 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.south)}",
                            prefixText: "南",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.required;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TextFormField(
                          onSaved: (value) {
                            playerNames[Position.west] = value!;
                          },
                          decoration: InputDecoration(
                            labelText:
                                "西 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.west)}",
                            prefixText: "西",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.required;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TextFormField(
                          onSaved: (value) {
                            playerNames[Position.north] = value!;
                          },
                          decoration: InputDecoration(
                            labelText:
                                "北 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.north)}",
                            prefixText: "北",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.required;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TextFormField(
                          onSaved: (value) {
                            playerNames[Position.extra] = value!;
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.positionPlayer(
                              AppLocalizations.of(context)!.extra,
                            ),
                          ),
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text(AppLocalizations.of(context)!.startGame),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              _createGame(playerNames).then((gameId) {
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                _navigateToGame(gameId);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _localizedHandPosition(Game game) {
    final Position position = game.currentHandNumber.position;
    final int roundHandNumber = game.currentHandNumber.roundHandNumber + 1;

    if (game.finished) {
      return '${AppLocalizations.of(context)!.finished} (${position.translatedString(context)} $roundHandNumber)';
    } else {
      return '${position.translatedString(context)} $roundHandNumber';
    }
  }
}

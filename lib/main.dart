import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'constants.dart';
import 'gamesheet.dart';
import 'locale_utils.dart';

var uuid = const Uuid();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCR Score Tracker',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(title: 'MCR Score Tracker'),
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
  String player1 = "";
  String player2 = "";
  String player3 = "";
  String player4 = "";
  String player5 = "";
  late List<String> gameIDs;
  final Map<String, String> games = HashMap();
  final Map<String, int> gameTurns = HashMap();
  final Map<String, List<String>> gamesPlayers = HashMap();
  final gameCards = <Widget>[];

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
    final prefs = await SharedPreferences.getInstance();
    games.clear();
    gameTurns.clear();
    gameCards.clear();

    setState(() {
      gameIDs = prefs.getKeys().toList();
      print("Loaded games : $gameIDs");
      for (String game in gameIDs) {
        List<String> gameData = prefs.getStringList(game) ?? [];
        if (gameData.isNotEmpty) {
          games[game] = gameData[0];
          gamesPlayers[game] = gameData.sublist(1);
          gameTurns[game] = base64Decode(gameData[0]).length ~/ 3;
          Widget card = _getNewCard(game);
          gameCards.add(card);
        }
      }
    });
    print(gameIDs);
  }

  Map<int, int> _getScore(String gameID) {
    Map<int, int> score = HashMap();
    int playersNum = gamesPlayers[gameID]!.length;
    for (int player = 0; player < playersNum; player++) {
      score[player] = 0;
    }
    List<int> game = base64Decode(games[gameID] ?? "");
    int hands = game.length ~/ 3;
    for (int hand = 0; hand < hands; hand++) {
      int handValue = game[3 * hand];
      int winner = game[3 * hand + 1];
      int loser = game[3 * hand + 2];
      print("$handValue $winner $loser");
      if (handValue > 0) {
        if (loser > 0) {
          // win off discard
          score[winner - 1] = score[winner - 1]! + 3 * 8 + handValue;
          for (int player = 0; player < playersNum; player++) {
            if (player == winner - 1 ||
                playersNum == 5 && fivePlayersHands[player][hand].isEmpty) {
              continue;
            }
            if (player == loser - 1) {
              score[player] = score[player]! - 8 - handValue;
            } else {
              score[player] = score[player]! - 8;
            }
          }
        } else {
          // self draw
          score[winner - 1] = score[winner - 1]! + 3 * (8 + handValue);
          for (int player = 0; player < playersNum; player++) {
            if (player == winner - 1 ||
                playersNum == 5 && fivePlayersHands[player][hand].isEmpty) {
              continue;
            }
            score[player] = score[player]! - 8 - handValue;
          }
        }
      }
      print(score);
    }
    return score;
  }

  String _getDesc(String gameID) {
    var desc = "";
    var scores = _getScore(gameID);
    print(scores);
    int playersNum = gamesPlayers[gameID]!.length;
    for (int player = 0; player < playersNum; player++) {
      desc += "${gamesPlayers[gameID]![player]} ${scores[player]}     ";
    }
    return desc;
  }

  Future<void> _createGame(
    String gameID,
    String player1,
    String player2,
    String player3,
    String player4,
    String player5,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> players = [player1, player2, player3, player4];
    if (player5.isNotEmpty) {
      players.add(player5);
    }
    gameIDs.add(gameID);
    gamesPlayers[gameID] = players;
    games[gameID] = "";
    gameTurns[gameID] = 0;
    List<String> data = [""] + players;
    prefs.setStringList(gameID, data);
    gameCards.add(_getNewCard(gameID));
    print("Created game $gameID");
    setState(() {});
  }

  Future<void> _showDeleteGameDialog(String gameID) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteQuestion),
          content: Text(AppLocalizations.of(context)!.deleteDialog),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteGame(gameID);
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

  Future<void> _deleteGame(String gameID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(gameID);
    gameIDs.remove(gameID);
    games.remove(gameID);
    gameTurns.remove(gameID);
    gamesPlayers.remove(gameID);
    gameCards.removeWhere((card) => card.key == Key(gameID));
    print("Deleted game $gameID");
    setState(() {});
  }

  void _reloadGame(String gameID) async {
    print("Reloading game $gameID");
    final prefs = await SharedPreferences.getInstance();
    List<String> gameData = prefs.getStringList(gameID) ?? [];
    if (gameData.isNotEmpty) {
      games[gameID] = gameData[0];
      gamesPlayers[gameID] = gameData.sublist(1);
      gameTurns[gameID] = base64Decode(gameData[0]).length ~/ 3;
      int index = gameCards.indexWhere((card) => card.key == Key(gameID));
      if (index >= 0) {
        gameCards.removeAt(index);
      }
      Widget newCard = _getNewCard(gameID);
      gameCards.insert(index, newCard);
      setState(() {});
    }
  }

  Widget _getNewCard(String gameID) {
    return Card(
      key: Key(gameID),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              '${AppLocalizations.of(context)!.game} ${getLocalizedWindTurn(context, handNames[gameTurns[gameID]!])}',
            ),
            subtitle: Text(_getDesc(gameID)),
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
                  _showDeleteGameDialog(gameID);
                },
              ),
              const Spacer(),
              TextButton(
                child:
                    gameTurns[gameID]! < 16
                        ? Text(AppLocalizations.of(context)!.continueButton)
                        : Text(AppLocalizations.of(context)!.viewButton),
                onPressed: () => _navigateToGame(gameID),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToGame(String gameID) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(gameID: gameID)),
    );
    _reloadGame(gameID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(child: Column(children: gameCards)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
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
                                  player1 = value!;
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      "東 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.east)}",
                                  prefixText: "東",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: TextFormField(
                                onSaved: (value) {
                                  player2 = value!;
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      "南 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.south)}",
                                  prefixText: "南",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: TextFormField(
                                onSaved: (value) {
                                  player3 = value!;
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      "西 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.west)}",
                                  prefixText: "西",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: TextFormField(
                                onSaved: (value) {
                                  player4 = value!;
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      "北 ${AppLocalizations.of(context)!.positionPlayer(AppLocalizations.of(context)!.north)}",
                                  prefixText: "北",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: TextFormField(
                                onSaved: (value) {
                                  player5 = value!;
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
                                child: Text(
                                  AppLocalizations.of(context)!.startGame,
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState?.save();
                                    String gameID = uuid.v4();
                                    _createGame(
                                      gameID,
                                      player1,
                                      player2,
                                      player3,
                                      player4,
                                      player5,
                                    ).then((value) {
                                      Navigator.of(context).pop();
                                      _navigateToGame(gameID);
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
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

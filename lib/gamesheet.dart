import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'dart:convert';
import 'constants.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.gameID});
  final String gameID;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _formKey = GlobalKey<FormState>();
  List<String> players = [];
  late List<int> playerScores;
  late List<int> gameData;
  int hand = 0;
  final List<List<int>> rowsData = [];
  String player1Wind = "";
  String player2Wind = "";
  String player3Wind = "";
  String player4Wind = "";
  String player5Wind = "";
  String handEnd = "draw";
  final List<String> handEndChoices = ["draw", "self", "offDiscard"];
  int currentHandValue = 0;
  int currentWinner = 0;
  String currentWinnerName = "";
  int currentLoser = 0;
  String currentLoserName = "";
  static const boldText = TextStyle(fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void didUpdateWidget(GamePage oldGamePage) {
    super.didUpdateWidget(oldGamePage);

    _loadGames();
  }

  bool _is5thPlayer(int player, int hand) {
    return players.length == 5 && fivePlayersHands[player][hand].isEmpty;
  }

  String _translateHandEnd(String handEnd) {
    switch (handEnd) {
      case "draw":
        return AppLocalizations.of(context)!.draw;
      case "self":
        return AppLocalizations.of(context)!.self;
      case "offDiscard":
        return AppLocalizations.of(context)!.offDiscard;
      default:
        return "";
    }
  }

  void _updatePlayersWinds(int hand) {
    if (hand >= 16) {
      player1Wind = "";
      player2Wind = "";
      player3Wind = "";
      player4Wind = "";
      player5Wind = "";
    } else if (players.length == 5) {
      player1Wind = windChars[fivePlayersHands[0][hand]]!;
      player2Wind = windChars[fivePlayersHands[1][hand]]!;
      player3Wind = windChars[fivePlayersHands[2][hand]]!;
      player4Wind = windChars[fivePlayersHands[3][hand]]!;
      player5Wind = windChars[fivePlayersHands[4][hand]]!;
    } else {
      player1Wind = windChars[fourPlayersHands[0][hand]]!;
      player2Wind = windChars[fourPlayersHands[1][hand]]!;
      player3Wind = windChars[fourPlayersHands[2][hand]]!;
      player4Wind = windChars[fourPlayersHands[3][hand]]!;
    }
    print(
      "$hand, '$player1Wind' '$player2Wind' '$player3Wind' '$player4Wind' '$player5Wind'",
    );
  }

  void _loadGames() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      List<String> data = prefs.getStringList(widget.gameID) ?? [];
      if (data.isNotEmpty) {
        gameData = base64Decode(data[0]);
        print("Loaded game : $gameData");
        hand = gameData.length ~/ 3;
        players = data.sublist(1);
        _updatePlayersWinds(hand);
        if (players.length == 5) {
          playerScores = [0, 0, 0, 0, 0];
        } else {
          playerScores = [0, 0, 0, 0];
        }
        _loadDataRows();
      }
    });
  }

  void _loadDataRows() {
    rowsData.clear();

    for (int handToAdd = 0; handToAdd < hand; handToAdd++) {
      int handValue = gameData[3 * handToAdd];
      int winner = gameData[3 * handToAdd + 1];
      int loser = gameData[3 * handToAdd + 2];
      _addNewScore(handToAdd, handValue, winner, loser);
    }
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> builtDataRows = [];
    //           E   S  W  N
    //           P1 P2 P3 P4 P5
    builtDataRows.add(_buildPlayerNames());
    builtDataRows.add(_buildPlayerTotal());

    for (int rowHand = 0; rowHand < rowsData.length / 2; rowHand++) {
      // TURN HAND -8 -8 -18 +x
      builtDataRows.add(
        DataRow(
          onLongPress: _showDeleteHandDialog,
          cells: [
            DataCell(
              Container(
                alignment: Alignment.center,
                child: Text(handNamesShort[rowHand]),
              ),
            ),
            DataCell(
              Container(
                alignment: Alignment.center,
                child: Text(rowsData[2 * rowHand][0].toString()),
              ),
            ),
            for (
              int playerIndex = 0;
              playerIndex < players.length;
              playerIndex++
            )
              DataCell(
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    rowsData[2 * rowHand][playerIndex + 1].toString(),
                  ),
                ),
              ),
          ],
        ),
      );
      // (total)    x   x  x  x  x
      builtDataRows.add(
        DataRow(
          onLongPress: _showDeleteHandDialog,
          cells: [
            DataCell(
              Container(
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context)!.total),
              ),
            ),
            const DataCell(Text("")),
            for (
              int playerIndex = 0;
              playerIndex < players.length;
              playerIndex++
            )
              DataCell(
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    rowsData[2 * rowHand + 1][playerIndex].toString(),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return builtDataRows;
  }

  DataRow _buildPlayerNames() {
    final double width = MediaQuery.of(context).size.width;

    return DataRow(
      cells: [
        DataCell(
          Center(
            child: Text(AppLocalizations.of(context)!.hand, style: boldText),
          ),
        ),
        DataCell(
          Center(
            child: Text(AppLocalizations.of(context)!.value, style: boldText),
          ),
        ),
        for (String player in players)
          DataCell(
            Container(
              alignment: Alignment.center,
              width: (width - 78) / (players.length + 2),
              child: Text(player, style: boldText),
            ),
          ),
      ],
    );
  }

  DataRow _buildPlayerTotal() {
    return DataRow(
      cells: [
        DataCell(
          Container(
            alignment: Alignment.center,
            child: Text(handNamesShort[hand], style: boldText),
          ),
        ),
        DataCell(Container(alignment: Alignment.center, child: Text(''))),
        for (int playerIndex = 0; playerIndex < players.length; playerIndex++)
          DataCell(
            Container(
              alignment: Alignment.center,
              child: Text(
                playerScores[playerIndex].toString(),
                style: boldText,
              ),
            ),
          ),
      ],
    );
  }

  void _addNewScore(int handToAdd, int handValue, int winner, int loser) {
    List<int> delta = [];
    for (int playerNum = 1; playerNum < players.length + 1; playerNum++) {
      if (handValue == 0 || _is5thPlayer(playerNum - 1, handToAdd)) {
        delta.add(0);
      } else if (loser == 0) {
        // self draw
        if (playerNum == winner) {
          delta.add(3 * (8 + handValue));
        } else {
          delta.add(-8 - handValue);
        }
      } else {
        // win off discard
        if (playerNum == winner) {
          delta.add(3 * 8 + handValue);
        } else if (playerNum == loser) {
          delta.add(-8 - handValue);
        } else {
          delta.add(-8);
        }
      }
    }
    for (int playerIndex = 0; playerIndex < players.length; playerIndex++) {
      playerScores[playerIndex] += delta[playerIndex];
    }

    rowsData.add([handValue] + delta);
    rowsData.add(List.from(playerScores));
  }

  Future<void> _saveHand() async {
    final prefs = await SharedPreferences.getInstance();
    gameData += [currentHandValue, currentWinner, currentLoser];
    print("Game : $gameData");
    prefs.setStringList(widget.gameID, [base64Encode(gameData)] + players);
    hand++;
    _updatePlayersWinds(hand);
    setState(() {});
  }

  Future<void> _showDeleteHandDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(
              context,
            )!.deleteQuestion(AppLocalizations.of(context)!.hand.toLowerCase()),
          ),
          content: Text(AppLocalizations.of(context)!.deleteHandDialog),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteLastHand();
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

  Future<void> _deleteLastHand() async {
    if (hand == 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    gameData = gameData.sublist(0, gameData.length - 3);
    print("Game : $gameData");
    prefs.setStringList(widget.gameID, [base64Encode(gameData)] + players);
    hand--;
    _updatePlayersWinds(hand);
    rowsData.removeRange(rowsData.length - 2, rowsData.length);
    playerScores =
        rowsData.isNotEmpty
            ? List.from(rowsData.last)
            : List.filled(players.length, 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.scoreSheet)),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:
                players.isNotEmpty
                    ? SizedBox(
                      width: width,
                      child: DataTable(
                        dataRowMaxHeight: double.infinity,
                        columnSpacing: 5.0,
                        columns: <DataColumn>[
                          DataColumn(label: const Text('')),
                          DataColumn(label: const Text('')),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                player1Wind,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                player2Wind,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                player3Wind,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                player4Wind,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          if (players.length == 5)
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  player5Wind,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: _buildDataRows(),
                      ),
                    )
                    : Text(AppLocalizations.of(context)!.loading),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: _showDeleteHandDialog,
              icon: Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.deleteLastHand,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Visibility(
        visible: hand < 16,
        child: FloatingActionButton.extended(
          onPressed: () {
            handEnd = "";
            currentHandValue = 0;
            currentWinner = 0;
            currentWinnerName = "";
            currentLoser = 0;
            currentLoserName = "";
            _showHandEndDialog().then(
              (value) => setState(() {
                if (value == 'ok') {
                  _addNewScore(
                    hand,
                    currentHandValue,
                    currentWinner,
                    currentLoser,
                  );
                  _saveHand();
                }
              }),
            );
          },
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.addHand),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future<dynamic> _showHandEndDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              content: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    right: -40.0,
                    top: -40.0,
                    child: InkResponse(
                      onTap: () {
                        Navigator.of(context).pop('close');
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
                            child: DropdownButtonFormField<String>(
                              onChanged: (String? value) {
                                setState(() {
                                  handEnd = value!;
                                });
                              },
                              items:
                                  handEndChoices.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(_translateHandEnd(value)),
                                    );
                                  }).toList(),
                              onSaved: (value) {
                                // TODO SAVE VALUE
                              },
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.handEnd,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.required;
                                }
                                // TODO CHECK
                                return null;
                              },
                            ),
                          ),
                          if (handEnd == "self" || handEnd == "offDiscard")
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'\d'),
                                  ),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onSaved: (value) {
                                  currentHandValue = int.parse(value!);
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.handValue,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      int.parse(value) < 8) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.moreThanEight;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          if (handEnd == "self" || handEnd == "offDiscard")
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DropdownButtonFormField<String>(
                                onChanged: (String? value) {
                                  setState(() {
                                    currentWinnerName = value!;
                                    currentWinner =
                                        players.indexOf(currentWinnerName) + 1;
                                  });
                                },
                                items:
                                    players
                                        .where(
                                          (player) =>
                                              player != currentLoserName &&
                                              !_is5thPlayer(
                                                players.indexOf(player),
                                                hand,
                                              ),
                                        )
                                        .map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        })
                                        .toList(),
                                onSaved: (value) {},
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.winner,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          if (handEnd == "offDiscard" && currentWinner > 0)
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DropdownButtonFormField<String>(
                                onChanged: (String? value) {
                                  setState(() {
                                    currentLoserName = value!;
                                    currentLoser =
                                        players.indexOf(currentLoserName) + 1;
                                  });
                                },
                                items:
                                    players
                                        .where(
                                          (player) =>
                                              player != currentWinnerName &&
                                              !_is5thPlayer(
                                                players.indexOf(player),
                                                hand,
                                              ),
                                        )
                                        .map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        })
                                        .toList(),
                                onSaved: (value) {},
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.giver,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: Text(
                                AppLocalizations.of(context)!.addHand,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState?.save();
                                  Navigator.of(context).pop('ok');
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
    );
  }
}

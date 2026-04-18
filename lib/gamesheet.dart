import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcr_tracker/src/game.dart';
import 'l10n/app_localizations.dart';
import 'src/game_storage.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.game});
  final Game game;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const TextStyle boldText = TextStyle(fontWeight: FontWeight.bold);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GameStorage storage = GameStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(GamePage oldGamePage) {
    super.didUpdateWidget(oldGamePage);
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> builtDataRows = [];
    //           E   S  W  N
    //           P1 P2 P3 P4 P5
    builtDataRows.add(_buildPlayerNames());
    builtDataRows.add(_buildPlayerTotal());

    final HandScores handScores = widget.game.handScores();

    widget.game.hands.forEachIndexed((index, hand) {
      final HandNumber handNumber = HandNumber(index);
      final PlayerScores playerScores = handScores.partial[index];
      final PlayerScores playerTotalScores = handScores.total[index + 1];

      // TURN HAND -8 -8 -18 +x
      builtDataRows.add(
        DataRow(
          onLongPress: _deleteHandDialog,
          cells: [
            DataCell(
              Container(
                alignment: Alignment.center,
                child: Text(_shortHandPosition(handNumber)),
              ),
            ),
            DataCell(
              Container(
                alignment: Alignment.center,
                child: Text(hand.value?.toString() ?? ''),
              ),
            ),
            for (final Player player in widget.game.playersSorted)
              DataCell(
                Container(
                  alignment: Alignment.center,
                  child: Text(playerScores[player].toString()),
                ),
              ),
          ],
        ),
      );

      // (total)    x   x  x  x  x
      builtDataRows.add(
        DataRow(
          color: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            return Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.15);
          }),
          onLongPress: _deleteHandDialog,
          cells: [
            DataCell(
              Container(
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context)!.total),
              ),
            ),
            const DataCell(Text('')),
            for (final Player player in widget.game.playersSorted)
              DataCell(
                Container(
                  alignment: Alignment.center,
                  child: Text(playerTotalScores[player].toString()),
                ),
              ),
          ],
        ),
      );
    });

    return builtDataRows;
  }

  DataRow _buildPlayerNames() {
    final double width = MediaQuery.of(context).size.width;
    final List<Player> players = widget.game.playersSorted;

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.5);
      }),
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
        for (final Player player in players)
          DataCell(
            Container(
              alignment: Alignment.center,
              width: (width - 78) / (players.length + 2),
              child: Text(player.name, style: boldText),
            ),
          ),
      ],
    );
  }

  DataRow _buildPlayerTotal() {
    final PlayerScores playerScores = widget.game.playerTotalScores();
    final List<Player> players = widget.game.playersSorted;

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);
      }),
      cells: [
        DataCell(
          Container(
            alignment: Alignment.center,
            child: Text('Current', style: boldText),
          ),
        ),
        DataCell(Container(alignment: Alignment.center, child: Text(''))),
        for (final Player player in players)
          DataCell(
            Container(
              alignment: Alignment.center,
              child: Text(playerScores[player].toString(), style: boldText),
            ),
          ),
      ],
    );
  }

  Future<void> _saveHand(Hand hand) async {
    widget.game.addHand(hand);
    await storage.saveGame(game: widget.game);
    setState(() {});
  }

  Future<void> _deleteHandDialog() async {
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
    if (widget.game.hands.isEmpty) return;
    final Hand lastHand = widget.game.hands.last;
    widget.game.removeHand(lastHand);
    storage.saveGame(game: widget.game);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final List<Player> players = widget.game.playersSorted;
    final HandNumber handNumber = widget.game.currentHandNumber;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.scoreSheet)),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: width,
              child: DataTable(
                dataRowMaxHeight: double.infinity,
                columnSpacing: 5.0,
                columns: <DataColumn>[
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        _shortHandPosition(handNumber),
                        style: boldText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(label: const Text('')),
                  for (final Player player in players)
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          player
                              .currentPosition(handNumber: handNumber)
                              .character,
                          style: boldText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
                rows: _buildDataRows(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: _deleteHandDialog,
              icon: Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.deleteLastHand,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Visibility(
        visible: !widget.game.finished,
        child: FloatingActionButton.extended(
          onPressed: _handEndDialog,
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.addHand),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future<dynamic> _handEndDialog() {
    HandEndKind? handEndKind;
    int? handValue;
    Player? winner;
    Player? giver;

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
                            child: DropdownButtonFormField<HandEndKind>(
                              onChanged: (HandEndKind? value) {
                                setState(() {
                                  handEndKind = value;
                                });
                              },
                              items:
                                  HandEndKind.values
                                      .map<DropdownMenuItem<HandEndKind>>((
                                        HandEndKind value,
                                      ) {
                                        return DropdownMenuItem<HandEndKind>(
                                          value: value,
                                          child: Text(
                                            value.translatedString(context),
                                          ),
                                        );
                                      })
                                      .toList(),
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.handEnd,
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(context)!.required;
                                }
                                return null;
                              },
                            ),
                          ),
                          if (handEndKind == HandEndKind.selfDraw ||
                              handEndKind == HandEndKind.offDiscard)
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
                                  handValue = int.parse(value!);
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
                          if (handEndKind == HandEndKind.selfDraw ||
                              handEndKind == HandEndKind.offDiscard)
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DropdownButtonFormField<Player>(
                                onChanged: (Player? value) {
                                  setState(() {
                                    winner = value;
                                  });
                                },
                                items:
                                    widget.game.playersSorted
                                        .where(
                                          (player) =>
                                              widget.game.isPlaying(player),
                                        )
                                        .map<DropdownMenuItem<Player>>((
                                          Player value,
                                        ) {
                                          return DropdownMenuItem<Player>(
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        })
                                        .toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.winner,
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          if (handEndKind == HandEndKind.offDiscard &&
                              winner != null)
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DropdownButtonFormField<Player>(
                                onChanged: (Player? value) {
                                  setState(() {
                                    giver = value;
                                  });
                                },
                                items:
                                    widget.game.playersSorted
                                        .where(
                                          (player) =>
                                              widget.game.isPlaying(player) &&
                                              player != winner,
                                        )
                                        .map<DropdownMenuItem<Player>>((
                                          Player value,
                                        ) {
                                          return DropdownMenuItem<Player>(
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        })
                                        .toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.giver,
                                ),
                                validator: (value) {
                                  if (value == null) {
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
                                  Hand hand = switch (handEndKind!) {
                                    HandEndKind.draw => Hand.draw(),
                                    HandEndKind.selfDraw => Hand.selfDraw(
                                      value: handValue!,
                                      winner: winner!,
                                    ),
                                    HandEndKind.offDiscard => Hand.offDiscard(
                                      value: handValue!,
                                      winner: winner!,
                                      giver: giver!,
                                    ),
                                  };

                                  Navigator.of(context).pop();

                                  _saveHand(hand);
                                  setState(() {});
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

  String _shortHandPosition(HandNumber handNumber) =>
      '${handNumber.position.character} - ${handNumber.roundHandNumber + 1}';
}

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/game/game.dart';
import 'l10n/app_localizations.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.game});
  final Game game;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const TextStyle _boldText = TextStyle(fontWeight: FontWeight.bold);
  static const int _columnNumber = 7;
  static const double _columnSpacing = 3.0;
  static const double _horizontalMargin = 6.0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _tableKey = GlobalKey();
  final GlobalKey _scaffoldKey = GlobalKey();
  final List<GlobalKey> _columnKeys = List.generate(
    _columnNumber,
    (_) => GlobalKey(),
  );
  final List<TableColumnWidth?> _columnWidths = List.filled(
    _columnNumber,
    null,
  );

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

    final Map gameScores =
        widget.game.gameScores() as Map<HandNumber, HandScores>;
    PlayerScores playerTotalScores = PlayerScores.zero(widget.game.players);

    for (final HandNumber handNumber in gameScores.keys) {
      if (!gameScores.containsKey(handNumber)) continue;
      final HandScores handScores = gameScores[handNumber]!;
      final HandEnd? hand = widget.game.hands[handNumber];

      String handPositionString = _shortHandPosition(handNumber);

      if (handScores.endScores != null) {
        final PlayerScores playerScores = handScores.endScores!;
        playerTotalScores += playerScores;

        // TURN HAND -8 -8 -18 +x
        builtDataRows.add(
          DataRow(
            onLongPress:
                widget.game.finished
                    ? null
                    : () => _deleteHandDialog(handNumber: handNumber),
            cells: [
              DataCell(Center(child: Text(handPositionString))),
              DataCell(Center(child: Text(hand?.value?.toString() ?? ''))),
              for (final Player player in widget.game.playersSorted)
                DataCell(
                  Center(child: Text((playerScores[player] ?? '-').toString())),
                ),
            ],
          ),
        );

        handPositionString = '';
      }

      if (handScores.penaltyScores != null &&
          handScores.penaltyScores!.isNotEmpty) {
        for (final (int index, PlayerScores playerScores)
            in handScores.penaltyScores!.indexed) {
          playerTotalScores += playerScores;

          // TURN HAND -8 -8 -18 +x
          builtDataRows.add(
            DataRow(
              onLongPress:
                  widget.game.finished
                      ? null
                      : () => _deletePenaltyDialog(
                        handNumber: handNumber,
                        index: index,
                      ),
              cells: [
                DataCell(Center(child: Text(handPositionString))),
                DataCell(Center(child: Icon(Icons.gavel, size: 20))),
                for (final Player player in widget.game.playersSorted)
                  DataCell(
                    Center(
                      child: Text((playerScores[player] ?? '-').toString()),
                    ),
                  ),
              ],
            ),
          );
          handPositionString = '';
        }
      } else if (handNumber == widget.game.currentHandNumber + 1) {
        break;
      }

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
          onLongPress:
              () =>
                  widget.game.finished
                      ? null
                      : _deleteHandDialog(handNumber: handNumber),
          cells: [
            DataCell(Center(child: Text(AppLocalizations.of(context)!.total))),
            const DataCell(Text('')),
            for (final Player player in widget.game.playersSorted)
              DataCell(
                Center(child: Text(playerTotalScores[player].toString())),
              ),
          ],
        ),
      );
    }

    return builtDataRows;
  }

  DataRow _buildPlayerNames() {
    final List<Player> players = widget.game.playersSorted;

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.5);
      }),
      cells: [
        DataCell(
          Center(
            child: Text(AppLocalizations.of(context)!.hand, style: _boldText),
          ),
        ),
        DataCell(
          Center(
            child: Text(AppLocalizations.of(context)!.value, style: _boldText),
          ),
        ),
        for (final Player player in players)
          DataCell(Center(child: Text(player.name, style: _boldText))),
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
            child: Text(AppLocalizations.of(context)!.score, style: _boldText),
          ),
        ),
        DataCell(Container(alignment: Alignment.center, child: Text(''))),
        for (final Player player in players)
          DataCell(
            Center(
              child: Text(playerScores[player].toString(), style: _boldText),
            ),
          ),
      ],
    );
  }

  Future<void> _saveHand(HandEnd hand) async {
    await widget.game.addHand(hand: hand);
    setState(() {});
  }

  Future<void> _savePenalty(Penalty penalty) async {
    await widget.game.addPenalty(penalty: penalty);
    setState(() {});
  }

  Future<void> _deleteHandDialog({HandNumber? handNumber}) async {
    if (widget.game.finished) return;
    final String handPosition =
        handNumber != null
            ? _shortHandPosition(handNumber)
            : AppLocalizations.of(context)!.last.toLowerCase();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(
              context,
            )!.deleteQuestion(AppLocalizations.of(context)!.hand.toLowerCase()),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteHandDialog(handPosition),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteHand(handNumber: handNumber);
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.delete.toUpperCase(),
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePenaltyDialog({
    HandNumber? handNumber,
    int? index,
  }) async {
    if (widget.game.finished) return;
    final String handPosition =
        handNumber != null
            ? _shortHandPosition(handNumber)
            : AppLocalizations.of(context)!.last.toLowerCase();
    final String indexString =
        index != null
            ? '#${index + 1}'
            : AppLocalizations.of(context)!.last.toLowerCase();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.deleteQuestion(
              AppLocalizations.of(context)!.penalty.toLowerCase(),
            ),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            )!.deletePenaltyDialog(indexString, handPosition),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deletePenalty(handNumber: handNumber, index: index);
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.delete.toUpperCase(),
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHand({HandNumber? handNumber}) async {
    if (widget.game.hands.isEmpty) return;
    final HandNumber lastHandNumber = HandNumber(widget.game.hands.length - 1);
    await widget.game.removeHand(handNumber: handNumber ?? lastHandNumber);
    setState(() {});
  }

  Future<void> _deletePenalty({HandNumber? handNumber, int? index}) async {
    if (widget.game.penalties.isEmpty) return;
    final HandNumber lastHandNumber = HandNumber(widget.game.hands.length - 1);
    await widget.game.removePenalty(
      handNumber: handNumber ?? lastHandNumber,
      index: index,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateColumnWidths(widget.game.players.length + 2),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.scoreSheet)),
      body: Column(
        children: [
          _gameTableHeader(),
          Expanded(child: SingleChildScrollView(child: _gameTable())),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _gameTableHeader(offstage: true),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: widget.game.finished ? null : _deleteHandDialog,
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.deleteLastHand,
            ),
            IconButton(
              onPressed:
                  widget.game.finished || !widget.game.canRestore
                      ? null
                      : widget.game.restoreLastHand,
              icon: const Icon(Icons.undo),
              tooltip: AppLocalizations.of(context)!.restoreLastHand,
            ),
            if (widget.game.finished)
              IconButton(
                onPressed: () => widget.game.resume(),
                icon: const Icon(Icons.play_arrow),
                tooltip: AppLocalizations.of(context)!.resume,
              ),
            if (!widget.game.finished)
              IconButton(
                onPressed: () => widget.game.finish(),
                icon: const Icon(Icons.check),
                tooltip: AppLocalizations.of(context)!.finish,
              ),
            IconButton(
              onPressed: widget.game.finished ? null : _penaltyDialog,
              icon: const Icon(Icons.gavel),
              tooltip: AppLocalizations.of(context)!.penalize,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Visibility(
        child: FloatingActionButton.extended(
          onPressed: widget.game.finished ? null : _handEndDialog,
          backgroundColor: widget.game.finished ? Colors.grey.shade200 : null,
          foregroundColor: widget.game.finished ? Colors.grey.shade600 : null,
          icon:
              widget.game.finished
                  ? const Icon(Icons.check)
                  : const Icon(Icons.add),
          label: Text(
            widget.game.finished
                ? AppLocalizations.of(context)!.finished
                : AppLocalizations.of(context)!.addHand,
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Offstage _gameTableHeader({bool offstage = false}) {
    final HandNumber handNumber = widget.game.currentHandNumber + 1;
    final List<Player> players = widget.game.playersSorted;
    final List<TableColumnWidth?> columnWidths =
        offstage ? List.filled(_columnNumber, null) : _columnWidths;
    final List<GlobalKey?> columnKeys =
        offstage ? _columnKeys : List.filled(_columnNumber, null);

    return Offstage(
      offstage: offstage,
      child: DataTable(
        key: offstage ? null : _tableKey,
        horizontalMargin: _horizontalMargin,
        dataRowMaxHeight: double.infinity,
        columnSpacing: _columnSpacing,
        columns: <DataColumn>[
          DataColumn(
            columnWidth: columnWidths[0] ?? IntrinsicColumnWidth(),
            label: Expanded(
              key: columnKeys[0],
              child: Text(
                widget.game.finished ? '' : _shortHandPosition(handNumber),
                style: _boldText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            columnWidth: columnWidths[1] ?? IntrinsicColumnWidth(),
            label: Expanded(key: columnKeys[1], child: const Text('')),
          ),
          for (final (int index, Player player) in players.indexed)
            DataColumn(
              columnWidth: columnWidths[index + 2] ?? IntrinsicColumnWidth(),
              //FlexColumnWidth(player.name.length.toDouble()),
              label: Expanded(
                key: columnKeys[index + 2],
                child: Text(
                  player
                      .currentPosition(
                        handNumber: handNumber,
                        withExtraPlayer: widget.game.withExtraPlayer,
                      )
                      .character,
                  style: _boldText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
        rows: [_buildPlayerNames(), _buildPlayerTotal()],
      ),
    );
  }

  DataTable _gameTable({bool offstage = false}) {
    final List<Player> players = widget.game.playersSorted;
    final List<TableColumnWidth?> columnWidths =
        offstage ? List.filled(_columnNumber, null) : _columnWidths;

    return DataTable(
      horizontalMargin: _horizontalMargin,
      dataRowMaxHeight: double.infinity,
      columnSpacing: _columnSpacing,
      headingRowHeight: 0,
      columns: <DataColumn>[
        DataColumn(
          columnWidth: columnWidths[0] ?? IntrinsicColumnWidth(),
          label: Container(),
        ),
        DataColumn(
          columnWidth: columnWidths[1] ?? IntrinsicColumnWidth(),
          label: Container(),
        ),
        for (int index = 0; index < players.length; index++)
          DataColumn(
            columnWidth: columnWidths[index + 2] ?? IntrinsicColumnWidth(),
            label: Container(),
          ),
      ],
      rows: _buildDataRows(),
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
                // clipBehavior: Clip.none,
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
                                  HandEnd hand = switch (handEndKind!) {
                                    HandEndKind.draw => HandEnd.draw(),
                                    HandEndKind.selfDraw => HandEnd.selfDraw(
                                      value: handValue!,
                                      winner: winner!,
                                    ),
                                    HandEndKind.offDiscard =>
                                      HandEnd.offDiscard(
                                        value: handValue!,
                                        winner: winner!,
                                        giver: giver!,
                                      ),
                                  };

                                  Navigator.of(context).pop();

                                  _saveHand(hand);
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

  Future<dynamic> _penaltyDialog() {
    Player? player;
    PenaltyKind? kind = PenaltyKind.pointPenalty;
    PenaltyReason? reason;
    PenaltyPoints? points;
    String? description;

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
                            child: DropdownButtonFormField<Player>(
                              onChanged: (Player? value) {
                                setState(() {
                                  player = value;
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
                                labelText: AppLocalizations.of(context)!.player,
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(context)!.required;
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: DropdownButtonFormField<PenaltyKind>(
                              initialValue: PenaltyKind.pointPenalty,
                              onChanged: (PenaltyKind? value) {
                                setState(() {
                                  kind = value;
                                });
                              },
                              items:
                                  PenaltyKind.values
                                      .map<DropdownMenuItem<PenaltyKind>>((
                                        PenaltyKind value,
                                      ) {
                                        return DropdownMenuItem<PenaltyKind>(
                                          value: value,
                                          child: Text(
                                            value.translatedString(context),
                                          ),
                                        );
                                      })
                                      .toList(),
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.penaltyKind,
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(context)!.required;
                                }
                                return null;
                              },
                            ),
                          ),
                          if (kind == PenaltyKind.pointPenalty)
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DropdownButtonFormField<PenaltyReason>(
                                onChanged: (PenaltyReason? value) {
                                  setState(() {
                                    reason = value;
                                  });
                                },
                                items:
                                    PenaltyReason.values.map<
                                      DropdownMenuItem<PenaltyReason>
                                    >((PenaltyReason value) {
                                      return DropdownMenuItem<PenaltyReason>(
                                        value: value,
                                        child: Text(
                                          value.translatedString(context),
                                        ),
                                      );
                                    }).toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(
                                        context,
                                      )!.penaltyReason,
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
                          if (kind == PenaltyKind.pointPenalty &&
                              reason?.points() == null)
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
                                  points = (
                                    deduced: int.parse(value!),
                                    perOpponent: points?.perOpponent ?? 0,
                                  );
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(
                                        context,
                                      )!.deducedPoints,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    AppLocalizations.of(context)!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          if (kind == PenaltyKind.pointPenalty &&
                              reason?.points() == null)
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
                                  points = (
                                    deduced: points?.deduced ?? 0,
                                    perOpponent: int.parse(value!),
                                  );
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(
                                        context,
                                      )!.pointsPerOpponent,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    AppLocalizations.of(context)!.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: TextFormField(
                              onSaved: (value) {
                                description = value;
                              },
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.description,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  AppLocalizations.of(context)!.required;
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
                                  Penalty penalty = Penalty(
                                    player: player!,
                                    kind: kind!,
                                    reason: reason!,
                                    penaltyPoints: points,
                                    description: description,
                                  );

                                  Navigator.of(context).pop();

                                  _savePenalty(penalty);
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
      '${handNumber.position.character}  ${handNumber.roundHandNumber + 1}';

  void _updateColumnWidths(int columnNumber) {
    if (!mounted) return;

    final List<double> widths = List.filled(_columnNumber, 0.0);

    for (final (int index, GlobalKey key) in _columnKeys.indexed) {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        widths[index] = renderBox.size.width;
      }
    }

    setState(() {
      final double? tableWidth = _tableKey.currentContext?.size?.width;
      if (tableWidth != null) {
        if (tableWidth / columnNumber - _columnSpacing - _horizontalMargin >
            widths.max) {
          _columnWidths.setAll(
            0,
            List.filled(_columnNumber, FractionColumnWidth(1 / columnNumber)),
          );
        } else {
          final int lastIndex = widths.lastIndexWhere((width) => width != 0);
          for (int index = 0; index < lastIndex; index++) {
            if (index <= 1) {
              _columnWidths[index] = MaxColumnWidth(
                IntrinsicColumnWidth(),
                FlexColumnWidth(widths[index] + _columnSpacing),
              );
            } else {
              _columnWidths[index] = FlexColumnWidth(
                widths[index] + _columnSpacing,
              );
            }
          }

          _columnWidths[lastIndex] = FlexColumnWidth(
            widths[lastIndex] + _columnSpacing + _horizontalMargin / 2,
          );
        }
      }
    });
  }
}

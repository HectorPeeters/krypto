import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/puzzle.dart';
import '../test_formatters.dart';

class PuzzleView extends StatefulWidget {
  final Puzzle puzzle;
  final List<List<TextEditingController>> textControllers;

  PuzzleView({
    super.key,
    required this.puzzle,
    List<String>? solution,
  }) : textControllers = [] {
    if (solution == null) {
      for (var row in puzzle.rows) {
        textControllers.add(
            row.answer.characters.map((_) => TextEditingController()).toList());
      }
      return;
    }

    for (var rowIndex = 0; rowIndex < puzzle.rows.length; rowIndex++) {
      var row = puzzle.rows[rowIndex];
      List<TextEditingController> controllers = [];

      for (var letterIndex = 0;
          letterIndex < row.answer.length;
          letterIndex++) {
        var letter = solution[rowIndex][letterIndex].toString();
        controllers.add(
            TextEditingController(text: letter.trim().isEmpty ? "" : letter));
      }

      textControllers.add(controllers);
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _PuzzleViewState();
  }
}

class _PuzzleViewState extends State<PuzzleView> {
  static const double letterWidth = 28;
  static const double letterHeight = 34;

  int _determineSolutionColumn() {
    var firstRow = widget.puzzle.rows[0];
    return firstRow.offset + firstRow.answer.indexOf(widget.puzzle.solution[0]);
  }

  int? _getLetterNumber(PuzzleRow row, int charIndex) {
    var numberIndex = row.numbers
        .where((n) => n.index == charIndex)
        .toList()
        .elementAtOrNull(0)
        ?.index;

    int? number;

    if (numberIndex != null) {
      number = widget.puzzle.legends
          .where((l) => l.letter == row.answer[numberIndex])
          .toList()[0]
          .number;
    }

    return number;
  }

  void _fillMatchingLetters(int letterNumber, String letter) {
    var rows = widget.puzzle.rows;

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      var row = rows[rowIndex];

      for (var letterIndex = 0;
          letterIndex < row.answer.length;
          letterIndex++) {
        var currentLetterNumber = _getLetterNumber(row, letterIndex);

        if (currentLetterNumber == letterNumber) {
          widget.textControllers[rowIndex][letterIndex].text = letter;
        }
      }
    }
  }

  Future<void> _saveSolution() async {
    List<String> solution = [];

    var rows = widget.puzzle.rows;

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      var row = rows[rowIndex];

      String rowSolution = "";
      for (var letterIndex = 0;
          letterIndex < row.answer.length;
          letterIndex++) {
        String letterValue = widget.textControllers[rowIndex][letterIndex].text;
        assert(letterValue.length <= 1);

        rowSolution += letterValue.isEmpty ? " " : letterValue;
      }
      assert(rowSolution.length == row.answer.length);

      solution.add(rowSolution);
    }

    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("puzzle_${widget.puzzle.id}", solution);
  }

  Widget _rowTextInput(BuildContext context, int rowIndex) {
    var row = widget.puzzle.rows[rowIndex];

    List<Widget> letterWidgets = [];

    int solutionColumn = _determineSolutionColumn();

    for (var i = 0; i < row.offset; i++) {
      letterWidgets.add(
        const Padding(
          padding: EdgeInsets.all(1.0),
          child: SizedBox(
            width: letterWidth,
            height: letterHeight,
          ),
        ),
      );
    }

    for (var i = 0; i < row.answer.characters.length; i++) {
      var controller = widget.textControllers[rowIndex][i];

      var letterNumber = _getLetterNumber(row, i);

      letterWidgets.add(
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Stack(
            children: [
              Container(
                width: letterWidth,
                height: letterHeight,
                decoration: BoxDecoration(
                  color: (i + row.offset - 1 == solutionColumn)
                      ? Colors.redAccent
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  inputFormatters: [UpperCaseTextFormatter()],
                  enableSuggestions: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      bottom: letterHeight * 0.4,
                    ),
                  ),
                  onTap: () {
                    controller.selection =
                        TextSelection.collapsed(offset: controller.text.length);
                  },
                  onChanged: (value) async {
                    if (letterNumber != null) {
                      _fillMatchingLetters(letterNumber, value);
                    }

                    if (value.length == 1 &&
                        i != row.answer.characters.length - 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (value.isEmpty && i != 0) {
                      FocusScope.of(context).previousFocus();
                    }

                    _saveSolution();
                  },
                ),
              ),
              letterNumber == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 1.0),
                      child: Text(
                        letterNumber.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: letterWidgets,
    );
  }

  Widget _puzzleRow(BuildContext context, int rowIndex) {
    var row = widget.puzzle.rows[rowIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.hint),
        const SizedBox(height: 4.0),
        _rowTextInput(context, rowIndex),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      itemCount: widget.puzzle.rows.length,
      itemBuilder: _puzzleRow,
    );
  }
}

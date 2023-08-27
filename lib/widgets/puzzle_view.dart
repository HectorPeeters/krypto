import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/puzzle.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PuzzleView extends StatelessWidget {
  static const double letterWidth = 28;
  static const double letterHeight = 34;

  final Puzzle puzzle;

  const PuzzleView({
    super.key,
    required this.puzzle,
  });

  int _determineSolutionColumn() {
    var firstRow = puzzle.rows[0];
    return firstRow.offset + firstRow.answer.indexOf(puzzle.solution[0]);
  }

  Widget _rowTextInput(BuildContext context, PuzzleRow row) {
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
      var controller = TextEditingController();

      var numberIndex = row.numbers
          .where((n) => n.index == i)
          .toList()
          .elementAtOrNull(0)
          ?.index;

      int? number;

      if (numberIndex != null) {
        number = puzzle.legends
            .where((l) => l.letter == row.answer[numberIndex])
            .toList()[0]
            .number;
      }

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
                  onChanged: (value) {
                    if (value.length == 1 &&
                        i != row.answer.characters.length - 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (value.isEmpty && i != 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                ),
              ),
              number == null
                  ? const Text("")
                  : Padding(
                      padding: const EdgeInsets.only(left: 1.0),
                      child: Text(
                        number.toString(),
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

  Widget _puzzleRow(BuildContext context, PuzzleRow row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.hint),
        _rowTextInput(context, row),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      itemCount: puzzle.rows.length,
      itemBuilder: (context, index) => _puzzleRow(context, puzzle.rows[index]),
    );
  }
}

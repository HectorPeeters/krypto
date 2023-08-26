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
  final Puzzle puzzle;

  const PuzzleView({
    super.key,
    required this.puzzle,
  });

  Widget _rowTextInput(BuildContext context, PuzzleRow row) {
    List<Widget> letterWidgets = [];
    FocusNode? focus;

    for (var i = 0; i < row.offset; i++) {
      letterWidgets.add(
        const Padding(
          padding: EdgeInsets.all(1.0),
          child: SizedBox(
            width: 24,
            height: 30,
          ),
        ),
      );
    }
    for (var i = 0; i < row.answer.characters.length; i++) {
      var nextFocus = FocusNode();

      letterWidgets.add(
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            width: 24,
            height: 30,
            color: Theme.of(context).colorScheme.primaryContainer,
            alignment: Alignment.center,
            child: TextField(
              focusNode: focus,
              autofocus: true,
              maxLength: 1,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  bottom: 15,
                ),
              ),
              onChanged: (value) {
                if (value.length == 1 &&
                    i != row.answer.characters.length - 1) {
                  FocusScope.of(context).requestFocus(nextFocus);
                }
              },
            ),
          ),
        ),
      );

      focus = nextFocus;
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
      padding: const EdgeInsets.all(8.0),
      itemCount: puzzle.rows.length,
      itemBuilder: (context, index) => _puzzleRow(context, puzzle.rows[index]),
    );
  }
}

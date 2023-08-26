import 'package:flutter/material.dart';

import '../models/puzzle.dart';

class PuzzleView extends StatelessWidget {
  final Puzzle puzzle;

  const PuzzleView({
    super.key,
    required this.puzzle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: puzzle.rows.map((r) => Text(r.hint)).toList(),
    );
  }
}

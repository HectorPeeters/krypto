final class Puzzle {
  final int id;
  final String title;
  final DateTime startDate;
  final String solution;
  final bool published;
  final List<PuzzleRow> rows;
  final List<PuzzleLegend> legends;

  Puzzle({
    required this.id,
    required this.title,
    required this.startDate,
    required this.solution,
    required this.published,
    required this.rows,
    required this.legends,
  });

  factory Puzzle.fromJson(dynamic json) {
    return Puzzle(
      id: json["id"],
      title: json["title"],
      startDate: DateTime.parse(json["start_date"]),
      solution: json["solution"],
      published: json["published"],
      rows: (json["rows"] as List<dynamic>).map(PuzzleRow.fromJson).toList(),
      legends: (json["legends"] as List<dynamic>)
          .map(PuzzleLegend.fromJson)
          .toList(),
    );
  }
}

final class PuzzleRow {
  final int id;
  final int offset;
  final String hint;
  final String answer;
  final int index;
  final List<PuzzleNumber> numbers;

  PuzzleRow({
    required this.id,
    required this.offset,
    required this.hint,
    required this.answer,
    required this.index,
    required this.numbers,
  });

  factory PuzzleRow.fromJson(dynamic json) {
    return PuzzleRow(
      id: json["id"],
      offset: json["offset"],
      hint: json["hint"],
      answer: json["answer"],
      index: json["index"],
      numbers: (json["numbers"] as List<dynamic>)
          .map(PuzzleNumber.fromJson)
          .toList(),
    );
  }
}

final class PuzzleNumber {
  final int id;
  final int index;

  PuzzleNumber({
    required this.id,
    required this.index,
  });

  factory PuzzleNumber.fromJson(dynamic json) {
    return PuzzleNumber(
      id: json["id"],
      index: json["index"],
    );
  }
}

final class PuzzleLegend {
  // NOTE: No clue why this id is a string all of a sudden..
  final String id;
  final int number;
  final String letter;

  PuzzleLegend({
    required this.id,
    required this.number,
    required this.letter,
  });

  factory PuzzleLegend.fromJson(dynamic json) {
    return PuzzleLegend(
      id: json["id"],
      number: json["number"],
      letter: json["letter"],
    );
  }
}

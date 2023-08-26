final class PuzzleSummary {
  int id;
  String title;
  DateTime startDate;
  bool published;

  PuzzleSummary({
    required this.id,
    required this.title,
    required this.startDate,
    required this.published,
  });

  factory PuzzleSummary.fromJson(dynamic json) {
    return PuzzleSummary(
      id: json["id"]!,
      title: json["title"]!,
      startDate: DateTime.parse(json["start_date"]!),
      published: json["published"]!,
    );
  }
}

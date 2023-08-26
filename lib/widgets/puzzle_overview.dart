import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
}

class PuzzleOverview extends StatelessWidget {
  final String _getPuzzlesQuery = """
query getPuzzles(\$limit: Int, \$page: Int, \$published: Boolean) {
  puzzles(limit: \$limit, page: \$page, published: \$published) {
    data {
      id
      title
      start_date
      published
      __typename
    }
    total
    __typename
  }
}
  """;

  const PuzzleOverview({super.key});

  List<PuzzleSummary> _convertPuzzles(List<dynamic> data) {
    return data
        .map((p) => PuzzleSummary(
              id: p["id"]!,
              title: p["title"]!,
              startDate: DateTime.parse(p["start_date"]!),
              published: p["published"]!,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(_getPuzzlesQuery), variables: const {
        "page": 1,
        "limit": 100,
      }),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) return Text(result.exception.toString());

        if (result.isLoading) return const CircularProgressIndicator();

        List? puzzleData = result.data?["puzzles"]?["data"];

        if (puzzleData == null) return const Text("No puzzles found");

        var puzzles = _convertPuzzles(puzzleData);

        return ListView.builder(
          itemCount: puzzles.length,
          itemBuilder: (context, index) {
            final puzzle = puzzles[index];

            return Card(
              child: ListTile(
                title: Text(
                  puzzle.title,
                  style: TextStyle(
                    decoration: puzzle.published
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
                trailing: const Icon(Icons.check),
              ),
            );
          },
        );
      },
    );
  }
}

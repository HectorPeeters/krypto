import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/puzzle_summary.dart';
import '../screens/puzzle_screen.dart';

const String _getPuzzlesQuery = """
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

class PuzzlesList extends StatelessWidget {
  const PuzzlesList({super.key});

  List<PuzzleSummary> _convertPuzzles(List<dynamic> data) {
    return data.map(PuzzleSummary.fromJson).toList();
  }

  Future<Widget> _getPuzzleIcon(int puzzleId) async {
    var prefs = await SharedPreferences.getInstance();
    var solution = prefs.getStringList("puzzle_$puzzleId");
    if (solution != null) {
      return const Icon(Icons.arrow_right);
    } else {
      return const Icon(Icons.add);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(_getPuzzlesQuery),
        variables: const {
          "page": 1,
          "limit": 200,
        },
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.hasException) return Text(result.exception.toString());

        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List? puzzleData = result.data?["puzzles"]?["data"];

        if (puzzleData == null) return const Text("No puzzles found");

        var puzzles = _convertPuzzles(puzzleData);

        return ListView.builder(
          itemCount: puzzles.length,
          itemBuilder: (context, index) {
            final puzzle = puzzles[index];

            return Card(
              child: ListTile(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PuzzleScreen(
                        puzzleSummary: puzzle,
                      ),
                    ),
                  );
                },
                title: Text(
                  puzzle.title,
                  style: TextStyle(
                    decoration: puzzle.published
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
                trailing: FutureBuilder(
                  future: _getPuzzleIcon(puzzle.id),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return snapshot.data!;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

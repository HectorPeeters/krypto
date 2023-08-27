import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:krypto/models/puzzle.dart';
import 'package:krypto/models/puzzle_summary.dart';
import 'package:krypto/widgets/puzzle_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _getPuzzleById = """
query getPuzzleById(\$id: ID!) {
  puzzle(id: \$id) {
    id
    title
    start_date
    solution
    published
    rows {
      id
      offset
      hint
      answer
      index
      numbers {
        id
        index
        __typename
      }
      __typename
    }
    legends {
      id
      number
      letter
      __typename
    }
    __typename
  }
}
""";

class PuzzleScreen extends StatelessWidget {
  final PuzzleSummary puzzleSummary;

  const PuzzleScreen({
    super.key,
    required this.puzzleSummary,
  });

  Future<List<String>?> _getPuzzleSolution(int puzzleId) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("puzzle_$puzzleId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(puzzleSummary.title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(_getPuzzleById),
          variables: {
            "id": puzzleSummary.id,
          },
        ),
        builder: (result, {refetch, fetchMore}) {
          if (result.hasException) return Text(result.exception.toString());

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          dynamic puzzleData = result.data?["puzzle"];

          if (puzzleData == null) return const Text("No puzzle found");

          var puzzle = Puzzle.fromJson(puzzleData);

          return FutureBuilder(
            future: _getPuzzleSolution(puzzle.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              return PuzzleView(
                puzzle: puzzle,
                solution: snapshot.data,
              );
            },
          );
        },
      ),
    );
  }
}

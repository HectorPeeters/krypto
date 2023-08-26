import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(_getPuzzlesQuery), variables: const {
        "published": true,
        "page": 1,
        "limit": 100,
      }),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) return Text(result.exception.toString());

        if (result.isLoading) return const CircularProgressIndicator();

        List? puzzles = result.data?["puzzles"]?["data"];

        if (puzzles == null) return const Text("No puzzles found");

        return ListView.builder(
          itemCount: puzzles.length,
          itemBuilder: (context, index) {
            final puzzle = puzzles[index];

            return Card(
              child: ListTile(
                title: Text(puzzle["title"]),
                trailing: const Icon(Icons.check),
              ),
            );
          },
        );
      },
    );
  }
}

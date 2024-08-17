import 'package:collection/collection.dart';
import 'package:gql/ast.dart' as ast;
import 'package:gql/language.dart' as lang;

void main() {
  final query = ast.FieldDefinitionNode(
    name: ast.NameNode(value: 'testQuery'),
    args: [
      ast.InputValueDefinitionNode(
        name: ast.NameNode(value: 'id'),
        type: ast.NamedTypeNode(name: ast.NameNode(value: 'string')),
      ),
      ast.InputValueDefinitionNode(
        name: ast.NameNode(value: 'name'),
        type: ast.NamedTypeNode(name: ast.NameNode(value: 'string')),
      ),
    ],
    type: ast.NamedTypeNode(name: ast.NameNode(value: 'Todo'), isNonNull: true),
  );

  final type = ast.ObjectTypeDefinitionNode(
      name: ast.NameNode(value: 'TestType'),
      fields: [
        ast.FieldDefinitionNode(
          name: ast.NameNode(value: 'name'),
          type: ast.NamedTypeNode(
            name: ast.NameNode(value: 'String'),
          ),
        )
      ]);

  final schema = ast.DocumentNode(definitions: [
    type,
    ast.ObjectTypeDefinitionNode(
      name: ast.NameNode(value: 'Query'),
      fields: [query],
    ),
  ]);

  // print('type:\n' + lang.printNode(type));
  // print('query:\n' + lang.printNode(query));
  // print('schema:\n' + lang.printNode(schema));

  final queryString = """
query test_query {
  testQuery(id: "3") {
    name
  },
  testQuery(id: "3") {
    id
  },
}

query test_query {
  testQuery(id: "3") {
    id
  },
}

mutation test_query {
  testQuery
}
""";
  final request = lang.parseString(queryString);
  final queryFinder =
      ast.AccumulatingVisitor<ast.FieldNode>(visitors: [QueryFinder()]);
  request.accept(queryFinder);
  final queries = queryFinder.accumulator;
  final requestQuery = queries.first;

  if (requestQuery.name.value != 'testQuery') {
    throw Exception('request type has no implementer ${testQuery.toString()}');
  }

  final id = requestQuery.arguments
      .firstWhere((arg) => arg.name.value == 'id')
      .value as ast.StringValueNode;
  final name =
      requestQuery.arguments.firstWhereOrNull((arg) => arg.name.value == 'name')
          as ast.StringValueNode?;
  final result = testQuery(id.value, name?.value);
  print(result);
}

class TestType {
  const TestType({required this.name});

  final String name;
}

TestType testQuery(String id, String? name) {
  return TestType(name: 'foo');
}

class QueryFinder extends ast.SimpleVisitor<List<ast.FieldNode>> {
  @override
  List<ast.FieldNode>? visitOperationDefinitionNode(
      ast.OperationDefinitionNode node) {
    return node.type == ast.OperationType.query
        ? node.selectionSet.selections
            .map((selection) => selection is ast.FieldNode ? selection : null)
            .nonNulls
            .toList()
        : null;
  }
}

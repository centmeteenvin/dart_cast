import 'package:dart_cast/dart_cast.dart';
import 'package:dart_cast/src/graphql/validation/graphql_validation.dart';
import 'package:gql/ast.dart' as ast;
import 'package:test/test.dart';

void main() {
  group('GraphQL request validation tests', () {
    test('A valid query gets parsed correctly', () {
      final query = r"""
query TestQuery($id: String) {
  TestedQuery(id: $id, parameter: "foo") {
    id,
    field,
  }
}
""";
      expect(() => parseIncomingRequest(query), returnsNormally);

      final parsed = parseIncomingRequest(query);
      expect(parsed.definitions, isNotEmpty);
      expect(parsed.definitions.first, isA<ast.OperationDefinitionNode>());

      final parsedQuery =
          parsed.definitions.first as ast.OperationDefinitionNode;
      expect(parsedQuery.name!.value, 'TestQuery');
      expect(parsedQuery.type, ast.OperationType.query);
      expect(parsedQuery.variableDefinitions, isNotEmpty);

      final variable = parsedQuery.variableDefinitions.first;
      expect(variable.defaultValue?.value, isNull);
      expect(variable.type, isA<ast.NamedTypeNode>());

      final variableType = variable.type as ast.NamedTypeNode;
      expect(variableType.name.value, 'String');

      expect(variable.variable.name.value, 'id');

      expect(parsedQuery.selectionSet.selections, isNotEmpty);
      expect(parsedQuery.selectionSet.selections.first, isA<ast.FieldNode>());

      final parsedQueryRequest =
          parsedQuery.selectionSet.selections.first as ast.FieldNode;
      expect(parsedQueryRequest.name.value, 'TestedQuery');
      expect(parsedQueryRequest.arguments.length, 2);
      expect(parsedQueryRequest.selectionSet?.selections.length, 2);

      final variableArgument = parsedQueryRequest.arguments.first;
      expect(variableArgument.name.value, 'id');
      expect(variableArgument.value, isA<ast.VariableNode>());
      expect((variableArgument.value as ast.VariableNode).name.value, 'id');

      final literalArgument = parsedQueryRequest.arguments[1];
      expect(literalArgument.name.value, 'parameter');
      expect(literalArgument.value, isA<ast.StringValueNode>());

      final literalArgumentValue = literalArgument.value as ast.StringValueNode;
      expect(literalArgumentValue.value, 'foo');
      expect(literalArgumentValue.isBlock, false);

      expect(parsedQueryRequest.selectionSet?.selections.first,
          isA<ast.FieldNode>());
      final idSelection =
          parsedQueryRequest.selectionSet!.selections.first as ast.FieldNode;
      expect(idSelection.name.value, 'id');

      expect(
          parsedQueryRequest.selectionSet?.selections[1], isA<ast.FieldNode>());
      final fieldSelection =
          parsedQueryRequest.selectionSet!.selections[1] as ast.FieldNode;
      expect(fieldSelection.name.value, 'field');
    });

    test('Invalid graphQL generates an exception', () {
      final query = 'This is not valid graphQL';
      expect(() => parseIncomingRequest(query),
          throwsA(isA<InvalidGraphQlException>()));
      expect(() => InvalidGraphQlException(Exception(), query).toString(),
          returnsNormally);
    });
  });
}

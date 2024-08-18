import 'package:dart_cast/src/graphql/gql_generator/generation_exceptions.dart';
import 'package:dart_cast/src/graphql/gql_generator/registries/input_registry.dart';
import 'package:dart_cast/src/graphql/gql_generator/registries/mutation_registry.dart';
import 'package:dart_cast/src/graphql/gql_generator/registries/type_registry.dart';
import 'package:gql/ast.dart' as ast;
import 'package:test/test.dart';

import 'mocks/query_registry_mocks.dart';
import 'mocks/type_registry_mocks.dart';

void main() {
  group('Mutation mock tests', () {
    test('A simple mutation generates the correct nodes', () {
      final returnType = getScalarTypeMock(nullable: false);

      final inputType = getScalarTypeMock(nullable: false);

      final query = getQueryElement(
          returnType: returnType,
          inputParameters: [
            getInputParameter(name: 'input', type: inputType, defaultValue: 1)
          ],
          queryName: 'testQuery',
          description: 'test descriptions');

      final registry = MutationRegistry(
          typeRegistry: TypeRegistry(), inputRegistry: InputRegistry());

      final typeNode = registry.create(query, trace: []);

      expect(typeNode.name.value, 'testQuery');
      expect(typeNode.type, isA<ast.NamedTypeNode>());
      expect(typeNode.description!.value, 'test descriptions');

      final returnTypeNode = typeNode.type as ast.NamedTypeNode;
      expect(returnTypeNode.isNonNull, true);
      expect(returnTypeNode.name.value, 'Int');

      final inputNode = typeNode.args.first;
      expect(inputNode.defaultValue, isA<ast.IntValueNode>());
      expect((inputNode.defaultValue as ast.IntValueNode).value, '1');
      expect(inputNode.name.value, 'input');
      expect(inputNode.type, isA<ast.NamedTypeNode>());
    });

    test('Throw an error when two queries of the same type occur', () {
      final returnType = getScalarTypeMock(nullable: false);

      final inputType = getScalarTypeMock(nullable: false);

      final query = getQueryElement(
          returnType: returnType,
          inputParameters: [
            getInputParameter(name: 'input', type: inputType, defaultValue: 1)
          ],
          queryName: 'testQuery',
          description: 'test descriptions');

      final registry = MutationRegistry(
          typeRegistry: TypeRegistry(), inputRegistry: InputRegistry());

      registry.create(query, trace: []);

      expect(() => registry.create(query, trace: [query]),
          throwsA(isA<DuplicateMutationError>()));
    });
  });
}

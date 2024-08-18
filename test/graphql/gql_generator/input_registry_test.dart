import 'package:dart_cast/src/graphql/gql_generator/generation_exceptions.dart';
import 'package:dart_cast/src/graphql/gql_generator/registries/input_registry.dart';
import 'package:gql/ast.dart' as ast;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks/type_registry_mocks.dart';

void main() {
  group('Test the type registry with mocks', () {
    test('Test if a scalar type generates the correct node', () {
      final mock = getScalarTypeMock(nullable: true);
      final registry = InputRegistry();

      final typeNode = registry.get(mock, trace: []);

      verify(() => mock.isDartCoreInt).called(1);
      expect(typeNode is ast.NamedTypeNode, true);
      final namedTypeNode = typeNode as ast.NamedTypeNode;
      expect(namedTypeNode.name.value, 'Int');
      expect(namedTypeNode.isNonNull, false);
    });

    test('Test if a data type generates all scalar fields and data fields', () {
      final className = 'Test';
      final mock = getDartTypeMock(
          nullable: true,
          fields: [(fieldName: 'test', nullable: true)],
          className: className);
      final registry = InputRegistry();

      final typeNode = registry.get(mock, trace: []);

      expect(typeNode is ast.NamedTypeNode, true);
      final namedTypeNode = typeNode as ast.NamedTypeNode;

      expect(namedTypeNode.name.value, className);
      expect(namedTypeNode.isNonNull, false);

      final typeDefinition = registry.definitions.values.first;

      expect(typeDefinition.name.value, className);

      final fieldOne = typeDefinition.fields.first;
      expect(fieldOne.name.value, 'test');
      expect((fieldOne.type as ast.NamedTypeNode).name.value, 'Int');
    });

    test('Test if a List type generates a list type graphql element', () {
      final childType = getScalarTypeMock(nullable: true);

      final listType = getListTypeMock(nullable: true, child: childType);

      expect(() => InputRegistry().get(listType, trace: []),
          throwsA(isA<ListInputElementError>()));
    });
  });
}

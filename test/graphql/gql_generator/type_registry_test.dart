import 'package:analyzer/dart/element/element.dart';
import 'package:dart_cast/src/graphql/gql_generator/generation_exceptions.dart';
import 'package:dart_cast/src/graphql/gql_generator/registries/type_registry.dart';
import 'package:gql/ast.dart' as ast;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks/type_registry_mocks.dart';

void main() {
  group('Test the type registry with mocks', () {
    test('Test if a scalar type generates the correct node', () {
      final mock = getScalarTypeMock(nullable: true);
      final registry = TypeRegistry();

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
      final registry = TypeRegistry();

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

      final typeNode = TypeRegistry().get(listType, trace: []);

      expect(typeNode, isA<ast.ListTypeNode>());

      final listTypeNode = typeNode as ast.ListTypeNode;

      expect(listTypeNode.isNonNull, false);
      expect(listTypeNode.type, isA<ast.NamedTypeNode>());

      final childNameNode = listTypeNode.type as ast.NamedTypeNode;

      expect(childNameNode.isNonNull, false);
      expect(childNameNode.name.value, 'Int');
    });

    test('A List type without a parameter generates an error', () {
      final childType = getScalarTypeMock(nullable: true);

      when(() => childType.isDartCoreInt).thenReturn(false);
      when(() => childType.isDartCoreList).thenReturn(true);

      expect(() => TypeRegistry().get(childType, trace: []),
          throwsA(isA<InvalidIterableTypeDeclarationError>()));
    });

    test('A class with non final fields throws an error', () {
      final classType =
          getDartTypeMock(className: 'Test', nullable: false, fields: []);
      final classElement = classType.element as ClassElement;

      when(() => classElement.hasNonFinalField).thenReturn(true);

      expect(() => TypeRegistry().get(classType, trace: [classElement]),
          throwsA(isA<NonFinalClassError>()));
    });

    test('A none scalar type without a element throws an error', () {
      final classType =
          getDartTypeMock(className: 'Test', nullable: false, fields: []);

      when(() => classType.element).thenReturn(null);
      expect(() => TypeRegistry().get(classType, trace: []),
          throwsA(isA<NoTypeElementError>()));

      try {
        TypeRegistry().get(classType, trace: []);
      } catch (e) {
        e.toString();
      }
    });
    test('A late field throws an error', () {
      final classType = getDartTypeMock(
          className: 'Test',
          nullable: false,
          fields: [(fieldName: 'late', nullable: false)]);
      final field = (classType.element as ClassElement).fields.first;

      when(() => field.isLate).thenReturn(true);

      expect(
          () => TypeRegistry().generateTypeForField(
              field, classType.element as ClassElement,
              trace: [field]),
          throwsA(isA<LateFieldClassError>()));
    });
  });
}

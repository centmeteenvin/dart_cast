import 'package:dart_cast/src/gql_generator/exceptions.dart';
import 'package:dart_cast/src/gql_generator/registries/input_registry.dart';
import 'package:dart_cast/src/gql_generator/registries/query_registry.dart';
import 'package:dart_cast/src/gql_generator/registries/registry_helpers.dart';
import 'package:dart_cast/src/gql_generator/registries/type_registry.dart';
import 'package:gql/ast.dart' as ast;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks/query_registry_mocks.dart';
import 'mocks/type_registry_mocks.dart';

void main() {
  group('Test the query registry with the mock', () {
    test('A single return type and parameter query generates the correct nodes',
        () {
      final returnType = getScalarTypeMock(nullable: false);

      final inputType = getScalarTypeMock(nullable: false);

      final query = getQueryElement(
          returnType: returnType,
          inputParameters: [
            getInputParameter(name: 'input', type: inputType, defaultValue: 1)
          ],
          queryName: 'testQuery',
          description: 'test descriptions');

      final registry = QueryRegistry(
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

    test('A default list type is not supporter', () {
      final inputTypeChild = getScalarTypeMock(nullable: false);

      final inputType = getInputParameter(
          name: 'input',
          type: getListTypeMock(nullable: false, child: inputTypeChild),
          defaultValue: 1);

      expect(() => inputType.defaultValue([]), throwsUnimplementedError);
    });

    test('A default data type value is not supported', () {
      final inputType =
          getDartTypeMock(className: 'Test', nullable: false, fields: []);

      final inputParameter =
          getInputParameter(name: 'input', type: inputType, defaultValue: 1);

      expect(() => inputParameter.defaultValue([]),
          throwsA(isA<InvalidDefaultValueError>()));
    });

    test('Test if the correct default value gets passed', () {
      final inputType = getScalarTypeMock(nullable: false);
      final inputParameter =
          getInputParameter(name: 'input', type: inputType, defaultValue: 1);

      expect(inputParameter.defaultValue([]), isA<ast.IntValueNode>());
      expect((inputParameter.defaultValue([]) as ast.IntValueNode).value, '1');

      when(() => inputType.isDartCoreInt).thenReturn(false);
      when(() => inputType.isDartCoreBool).thenReturn(true);
      when(() => inputParameter.defaultValueCode).thenReturn('true');

      expect(inputParameter.defaultValue([]), isA<ast.BooleanValueNode>());
      expect((inputParameter.defaultValue([]) as ast.BooleanValueNode).value,
          true);

      when(() => inputType.isDartCoreBool).thenReturn(false);
      when(() => inputType.isDartCoreDouble).thenReturn(true);
      when(() => inputParameter.defaultValueCode).thenReturn('1.0');

      expect(inputParameter.defaultValue([]), isA<ast.FloatValueNode>());
      expect(
          (inputParameter.defaultValue([]) as ast.FloatValueNode).value, '1.0');

      when(() => inputType.isDartCoreDouble).thenReturn(false);
      when(() => inputType.isDartCoreString).thenReturn(true);
      when(() => inputParameter.defaultValueCode).thenReturn('test');

      expect(inputParameter.defaultValue([]), isA<ast.StringValueNode>());
      expect((inputParameter.defaultValue([]) as ast.StringValueNode).value,
          'test');
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

      final registry = QueryRegistry(
          typeRegistry: TypeRegistry(), inputRegistry: InputRegistry());

      registry.create(query, trace: []);

      expect(() => registry.create(query, trace: [query]),
          throwsA(isA<DuplicateQueryError>()));
    });
  });
}

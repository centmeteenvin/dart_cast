import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source.dart';
import 'package:dart_cast/src/graphql/gql_generator/registries/registry_helpers.dart';
import 'package:mocktail/mocktail.dart';

class ScalarTypeMock extends Mock implements DartType {}

class FieldElementMock extends Mock implements FieldElement {}

class DataTypeMock extends Mock implements DartType {}

class DataClassMock extends Mock implements ClassElement {}

class ListTypeMock extends Mock implements ParameterizedType {}

class SourceMock extends Mock implements Source {}

ScalarTypeMock getScalarTypeMock({required bool nullable}) {
  final mock = ScalarTypeMock();
  when(() => mock.isDartCoreInt).thenReturn(true);
  when(() => mock.isDartCoreBool).thenReturn(false);
  when(() => mock.isDartCoreDouble).thenReturn(false);
  when(() => mock.isDartCoreString).thenReturn(false);
  when(() => mock.nullabilitySuffix).thenReturn(
      nullable ? NullabilitySuffix.question : NullabilitySuffix.none);
  when(() => mock.getDisplayString()).thenReturn('Int');
  return mock;
}

DataTypeMock getDartTypeMock(
    {required String className,
    required bool nullable,
    required List<({String fieldName, bool nullable})> fields}) {
  final dataType = DataTypeMock();
  when(() => dataType.isDartCoreInt).thenReturn(false);
  when(() => dataType.isDartCoreString).thenReturn(false);
  when(() => dataType.isDartCoreBool).thenReturn(false);
  when(() => dataType.isDartCoreDouble).thenReturn(false);
  when(() => dataType.isDartCoreList).thenReturn(false);
  when(() => dataType.isScalar).thenReturn(false);
  when(() => dataType.nullabilitySuffix).thenReturn(
      nullable ? NullabilitySuffix.question : NullabilitySuffix.none);

  when(() => dataType.getDisplayString()).thenReturn(className);

  final classElement = DataClassMock();
  final source = SourceMock();

  when(() => source.fullName).thenReturn('lib');

  when(() => dataType.element).thenReturn(classElement);
  when(() => classElement.hasNonFinalField).thenReturn(false);
  when(() => classElement.name).thenReturn(className);
  when(() => classElement.getDisplayString()).thenReturn(className);

  when(() => classElement.source).thenReturn(source);

  final fieldElements = fields.map((field) {
    final fieldElement = FieldElementMock();
    when(() => fieldElement.name).thenReturn(field.fieldName);
    when(() => fieldElement.getDisplayString()).thenReturn(field.fieldName);
    when(() => fieldElement.type)
        .thenAnswer((_) => getScalarTypeMock(nullable: field.nullable));
    when(() => fieldElement.isFinal).thenReturn(true);
    when(() => fieldElement.isLate).thenReturn(false);
    return fieldElement;
  }).toList();

  when(() => classElement.fields).thenReturn(fieldElements);
  return dataType;
}

ListTypeMock getListTypeMock(
    {required bool nullable, required DartType child}) {
  final listType = ListTypeMock();
  when(() => listType.isDartCoreInt).thenReturn(false);
  when(() => listType.isDartCoreString).thenReturn(false);
  when(() => listType.isDartCoreBool).thenReturn(false);
  when(() => listType.isDartCoreDouble).thenReturn(false);
  when(() => listType.isDartCoreList).thenReturn(true);
  when(() => listType.isScalarIterable).thenReturn(true);
  when(() => listType.nullabilitySuffix).thenReturn(
      nullable ? NullabilitySuffix.question : NullabilitySuffix.none);

  when(() => listType.typeArguments).thenReturn([child]);
  when(() => listType.getDisplayString()).thenReturn('List');

  return listType;
}

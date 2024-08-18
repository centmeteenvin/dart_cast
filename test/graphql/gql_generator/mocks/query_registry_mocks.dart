import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:mocktail/mocktail.dart';

class QueryElementMock extends Mock implements FunctionElement {}

class InputParameterMock extends Mock implements ParameterElement {}

QueryElementMock getQueryElement(
    {required DartType returnType,
    required List<ParameterElement> inputParameters,
    required String queryName,
    String? description}) {
  final mock = QueryElementMock();

  when(() => mock.name).thenReturn(queryName);
  when(() => mock.returnType).thenReturn(returnType);
  when(() => mock.parameters).thenReturn(inputParameters);
  when(() => mock.documentationComment).thenReturn(description);

  return mock;
}

InputParameterMock getInputParameter(
    {required String name,
    required DartType type,
    required int? defaultValue}) {
  final mock = InputParameterMock();

  when(() => mock.name).thenReturn(name);
  when(() => mock.type).thenReturn(type);
  when(() => mock.type).thenReturn(type);
  when(() => mock.hasDefaultValue).thenReturn(defaultValue != null);
  when(() => mock.defaultValueCode).thenReturn(defaultValue?.toString());
  // when(() => mock.defaultValue([])).thenReturn(defaultValue == null
  //     ? null
  //     : ast.IntValueNode(value: defaultValue.toString()));

  return mock;
}

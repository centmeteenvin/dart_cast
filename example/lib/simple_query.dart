import 'package:dart_cast/dart_cast.dart';

class SimpleType {
  final String stringField;
  final double doubleField;
  final bool boolField;
  final int intField;
  final String? nullableField;

  final List<String> listField;
  final List<String>? nullableListField;
  final List<String?> listNullableField;
  final List<String?>? doubleNullableField;

  SimpleType(
      {required this.stringField,
      required this.doubleField,
      required this.boolField,
      required this.intField,
      required this.nullableField,
      required this.listField,
      required this.nullableListField,
      required this.listNullableField,
      required this.doubleNullableField});
}

class PositionalParameter {
  final String? foo = null;
}

class NamedParameter {
  final int? foo = 0;
  final InsideInputParameterWithReference? insideInputParameter = null;
}

class InsideInputParameterWithReference {
  final String? foo = '';
  final NamedParameter? backReference = null;
}

//
@GraphQL(Operation.query)
List<SimpleType> simpleTypeQuery(PositionalParameter emptyParameter,
    {required NamedParameter namedParameter, String defaultValue = 'foo'}) {
  return [];
}

@GraphQL(Operation.query)
SimpleType? simpleTypeQueryNullable() {
  return null;
}

@GraphQL(Operation.query)
List<SimpleType> simpleTypeList() {
  return [];
}

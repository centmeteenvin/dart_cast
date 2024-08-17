import 'package:dart_cast/dart_cast.dart';

@GraphQL(Operation.query)
String simpleQuery() {
  return '';
}

@GraphQL(Operation.query)
String? simpleQueryNullable() {
  return '';
}

@GraphQL(Operation.query)
List<String> simpleQueryList() {
  return [];
}

@GraphQL(Operation.query)
List<String?> simpleQueryListWithNullable() {
  return [];
}

@GraphQL(Operation.query)
List<String>? simpleQueryListNullable() {
  return null;
}

@GraphQL(Operation.query)
List<String?>? simpleQueryListDoubleNullable() {
  return null;
}

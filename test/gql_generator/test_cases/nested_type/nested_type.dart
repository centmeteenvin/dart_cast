import 'package:dart_cast/dart_cast.dart';

class A {
  final B b;

  A({required this.b});
}

class B {
  final String string;

  B({required this.string});
}

@GraphQL(Operation.query)
A? testQuery() {
  return null;
}

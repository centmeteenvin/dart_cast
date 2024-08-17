import 'package:dart_cast/dart_cast.dart';

class A {
  final B? b;

  A({required this.b});
}

class B {
  final A? a;
  final B? b = null;

  B({required this.a});
}

@GraphQL(Operation.query)
A? testQuery() {
  return null;
}

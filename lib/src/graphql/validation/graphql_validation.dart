import 'package:dart_cast/dart_cast.dart';
import 'package:gql/ast.dart' as ast;
import 'package:gql/language.dart' as lang;

/// Parse the given string into a graphQL document node
/// If a syntax error occurs a [InvalidGraphQLException] will be thrown
ast.DocumentNode parseIncomingRequest(String request) {
  try {
    return lang.parseString(request);
  } on Exception catch (e) {
    throw InvalidGraphQlException(e, request);
  }
}

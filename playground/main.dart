import 'dart:io';

import 'package:gql/operation.dart' as gql_op;
import 'package:gql/schema.dart' as gql_schema;
import 'package:gql/language.dart' as lang;

void main() {
  final schemaDefinition = lang.parseString(File('./schema.graphql').readAsStringSync());
  final schema = gql_schema.GraphQLSchema.fromNode(schemaDefinition);
  final testType = schema.getType('Test') as gql_schema.ObjectTypeDefinition;
  print(testType);

  final queryDefintion = lang.parseString(File('./test_query.gql').readAsStringSync());
  final query = gql_op.ExecutableDocument(queryDefintion, schema.getType);
}

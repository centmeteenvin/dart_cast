import 'package:build/build.dart';
import 'package:dart_cast/src/gql_generator/registries/input_registry.dart';
import 'package:dart_cast/src/gql_generator/registries/mutation_registry.dart';
import 'package:dart_cast/src/gql_generator/registries/query_registry.dart';
import 'package:dart_cast/src/gql_generator/registries/type_registry.dart';
import 'package:source_gen/source_gen.dart';

import 'generators.dart';

Builder graphQlSchemaBuilder(BuilderOptions options) {
  final typeRegistry = TypeRegistry();
  final inputRegistry = InputRegistry();

  final queryRegistry =
      QueryRegistry(typeRegistry: typeRegistry, inputRegistry: inputRegistry);
  final mutationRegistry = MutationRegistry(
      typeRegistry: typeRegistry, inputRegistry: inputRegistry);

  return LibraryBuilder(
    QuerySchemaGenerator(
        queryRegistry: queryRegistry,
        mutationRegistry: mutationRegistry,
        typeRegistry: typeRegistry,
        inputRegistry: inputRegistry),
    generatedExtension: '.g.dart',
  );
}

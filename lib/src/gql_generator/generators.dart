import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dart_cast/src/gql_generator/registries/input_registry.dart';
import 'package:dart_cast/src/gql_generator/registries/mutation_registry.dart';
import 'package:gql/ast.dart' as ast;
import 'package:gql/language.dart' as lang;
import 'package:source_gen/source_gen.dart';

import './annotations.dart';
import './registries/query_registry.dart';
import './registries/type_registry.dart';

class QuerySchemaGenerator extends GeneratorForAnnotation<GraphQL> {
  QuerySchemaGenerator() {}

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (!(element is FunctionElement)) {
      throw InvalidGenerationSource(
          'The [@Query] annotation should only be used on functions',
          element: element);
    }
    final operation = Operation.values[annotation.objectValue
        .getField('operation')!
        .getField('index')!
        .toIntValue()!];

    switch (operation) {
      case Operation.query:
        {
          QueryRegistry.instance.create(element, trace: [element]);
        }
      case Operation.mutation:
        {
          MutationRegistry.instance.create(element, trace: [element]);
        }
    }
  }

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    print('called');
    await super.generate(library, buildStep);
    final types = TypeRegistry.instance.definitions.values;
    final queryTypes = QueryRegistry.instance.definitions.values;
    final inputTypes = InputRegistry.instance.definitions.values;

    final schema = ast.DocumentNode(definitions: [
      ...types,
      ...inputTypes,
      ast.ObjectTypeDefinitionNode(
        name: ast.NameNode(value: 'Query'),
        fields: queryTypes.toList(),
      )
    ]);

    final outputDirectory = Directory('./lib/generated/graphql');
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }
    final schemaFile = File('${outputDirectory.path}/schema.graphql');
    schemaFile.writeAsStringSync(lang.printNode(schema));
    return '';
  }
}

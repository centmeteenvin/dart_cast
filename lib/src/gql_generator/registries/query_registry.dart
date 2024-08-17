/// This file contains a Registry singleton that Generates the necessary
/// Query definitions

import 'package:analyzer/dart/element/element.dart';
import 'package:dart_cast/src/gql_generator/registries/input_registry.dart';
import 'package:gql/ast.dart' as ast;

import '../exceptions.dart';
import '../registries/type_registry.dart';
import './registry_helpers.dart';

class QueryRegistry {
  static QueryRegistry? _instance = null;

  final Map<String, ast.FieldDefinitionNode> definitions = {};

  static QueryRegistry get instance {
    if (_instance == null) {
      _instance = QueryRegistry();
    }
    return _instance!;
  }

  ast.FieldDefinitionNode create(FunctionElement element,
      {required List<Element> trace}) {
    if (definitions.containsKey(element.name)) {
      throw DuplicateQueryError(trace: trace);
    }

    final typeRegistry = TypeRegistry.instance;
    final inputRegistry = InputRegistry.instance;

    final definition = ast.FieldDefinitionNode(
      name: ast.NameNode(value: element.name),
      description: element.description,
      type: typeRegistry.get(element.returnType, trace: trace),
      args: element.parameters
          .map((parameter) => ast.InputValueDefinitionNode(
                name: ast.NameNode(value: parameter.name),
                type: inputRegistry
                    .get(parameter.type, trace: [...trace, parameter]),
                defaultValue: parameter.defaultValue([...trace, parameter]),
                description: parameter.description,
              ))
          .toList(),
    );

    definitions[element.name] = definition;
    return definition;
  }
}

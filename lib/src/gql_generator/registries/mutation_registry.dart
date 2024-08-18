/// This file contains a Registry singleton that Generates the necessary
/// Query definitions

import 'package:analyzer/dart/element/element.dart';
import 'package:dart_cast/src/gql_generator/registries/input_registry.dart';
import 'package:gql/ast.dart' as ast;

import '../exceptions.dart';
import '../registries/type_registry.dart';
import './registry_helpers.dart';

class MutationRegistry {
  final Map<String, ast.FieldDefinitionNode> definitions = {};

  final TypeRegistry typeRegistry;
  final InputRegistry inputRegistry;

  MutationRegistry({required this.typeRegistry, required this.inputRegistry});

  ast.FieldDefinitionNode create(FunctionElement element,
      {required List<Element> trace}) {
    if (definitions.containsKey(element.name)) {
      throw DuplicateMutationError(trace: trace);
    }

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

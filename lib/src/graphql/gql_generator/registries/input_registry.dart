/// This file contains registry objects implemented as Singletons.
/// Their purpose is to hold the types that are being generated and cache them
/// This aims to improve inference time.
/// At the end of the procedure everything should be collected and parsed into a schema field.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:gql/ast.dart' as ast;

import '../exceptions.dart';
import './registry_helpers.dart';

class InputRegistry {
  /// This map holds all the definitions and is keyed by a hash on the name and library field.
  final Map<int, ast.InputObjectTypeDefinitionNode> definitions = {};

  ast.TypeNode get(DartType type, {required List<Element> trace}) {
    final scalarType = scalarTypeOrNull(type);
    if (scalarType != null) {
      return scalarType;
    }

    if (type.isDartCoreList) {
      throw ListInputElementError(trace: trace, type: type);
    }
    return getTypeFromObject(type, trace: trace);
  }

  ast.NamedTypeNode? scalarTypeOrNull(DartType type) {
    final isNonNull = type.isNonNull;
    String? name = null;
    if (type.isDartCoreInt) {
      name = 'Int';
    } else if (type.isDartCoreDouble) {
      name = 'Float';
    } else if (type.isDartCoreString) {
      name = 'String';
    } else if (type.isDartCoreBool) {
      name = 'Boolean';
    }

    return name != null
        ? ast.NamedTypeNode(
            name: ast.NameNode(value: name),
            isNonNull: isNonNull,
          )
        : null;
  }

  ast.TypeNode getTypeFromObject(DartType type,
      {required List<Element> trace}) {
    if (type.element == null || !(type.element is ClassElement)) {
      throw NoTypeElementError(trace: trace, type: type);
    }

    final classElement = type.element as ClassElement;

    if (classElement.hasNonFinalField) {
      throw NonFinalClassError(trace: trace);
    }
    if (!trace.any((element) => element.name == classElement.name)) {
      registerTypeDefinition(classElement, trace: [...trace, classElement]);
    }

    return ast.NamedTypeNode(
      name: ast.NameNode(value: classElement.name),
      isNonNull: type.isNonNull,
    );
  }

  /// Register a certain type for definition generation. If the definition already exist it will not
  void registerTypeDefinition(ClassElement classElement,
      {required List<Element> trace}) {
    //Try to check if the definition already exists
    final classKey =
        (classElement.name + classElement.source.fullName).hashCode;
    if (definitions.containsKey(classKey)) {
      return;
    }

    final definition = ast.InputObjectTypeDefinitionNode(
      name: ast.NameNode(value: classElement.name),
      description: classElement.description,
      fields: classElement.fields
          .map((field) => ast.InputValueDefinitionNode(
              name: ast.NameNode(value: field.name),
              type: get(field.type, trace: [...trace, field]),
              description: field.description))
          .toList(),
    );
    definitions[classKey] = definition;
  }
}

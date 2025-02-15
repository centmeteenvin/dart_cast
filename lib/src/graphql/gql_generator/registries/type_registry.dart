/// This file contains registry objects implemented as Singletons.
/// Their purpose is to hold the types that are being generated and cache them
/// This aims to improve inference time.
/// At the end of the procedure everything should be collected and parsed into a schema field.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:gql/ast.dart' as ast;

import '../generation_exceptions.dart';
import './registry_helpers.dart';

class TypeRegistry {
  /// This map holds all the definitions and is keyed by a hash on the name and library field.
  final Map<int, ast.ObjectTypeDefinitionNode> definitions = {};

  ast.TypeNode get(DartType type, {required List<Element> trace}) {
    final scalarType = scalarTypeOrNull(type);
    if (scalarType != null) return scalarType;

    if (type.isDartCoreList) {
      return ast.ListTypeNode(
          isNonNull: type.isNonNull,
          type: getTypeParameter(type, trace: trace));
    }

    return getTypeFromObject(type, trace: trace);
  }

  ast.TypeNode? scalarTypeOrNull(DartType type) {
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

  ast.TypeNode getTypeParameter(DartType type, {required List<Element> trace}) {
    if (!(type is ParameterizedType)) {
      throw InvalidIterableTypeDeclarationError(trace: trace, type: type);
    }
    final parameterType = type.typeArguments.first;
    return get(parameterType, trace: trace);
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

    final definition = ast.ObjectTypeDefinitionNode(
      name: ast.NameNode(value: classElement.name),
      description: classElement.description,
      fields: classElement.fields
          .map(
            (field) => generateTypeForField(field, classElement,
                trace: [...trace, field]),
          )
          .toList(),
    );
    definitions[classKey] = definition;
  }

  /// Generates a type for a given field and assumes the field is final
  /// The purpose of this function is to ensure we can create the an instance of the class using the unnamed constructor
  ast.FieldDefinitionNode generateTypeForField(
      FieldElement fieldElement, ClassElement classElement,
      {required List<Element> trace}) {
    if (fieldElement.isFinal && fieldElement.isLate) {
      throw LateFieldClassError(trace: trace);
    }
    {
      return ast.FieldDefinitionNode(
          name: ast.NameNode(value: fieldElement.name),
          description: fieldElement.description,
          type: get(fieldElement.type, trace: [...trace, fieldElement]));
    }
  }
}

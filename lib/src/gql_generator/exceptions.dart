import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class GraphQLGeneratorError extends Error {
  GraphQLGeneratorError({required this.trace, this.message});

  final List<Element> trace;
  final String? message;

  @override
  String toString() {
    return '$message\n\nThis error occurred with the following trace ${trace.map((element) => element.name)}';
  }
}

class InvalidTypeDeclarationError extends GraphQLGeneratorError {
  InvalidTypeDeclarationError(
      {required super.trace, required this.type, required String message})
      : super(
            message:
                "$message\nThe field in question was ${type.getDisplayString()}");

  final DartType type;
}

/// Created when no type parameter was given to an iterable field.
class InvalidIterableTypeDeclarationError extends InvalidTypeDeclarationError {
  InvalidIterableTypeDeclarationError(
      {required super.trace, required super.type})
      : super(
          message: "An Iterable type must have a type parameter definition",
        );
}

class NoTypeElementError extends InvalidTypeDeclarationError {
  NoTypeElementError({required super.trace, required super.type})
      : super(
            message:
                "All Types must refer to a valid Class or be a GraphQL Scalar");
}

class ListInputElementError extends InvalidTypeDeclarationError {
  ListInputElementError({required super.trace, required super.type})
      : super(message: 'Iterable Input parameters are not supported');
}

class InvalidClassDeclarationError extends GraphQLGeneratorError {
  InvalidClassDeclarationError({required super.trace, required String message})
      : super(message: '$message\nThe Class in question: ${trace.last.name}');
}

class NonFinalClassError extends InvalidClassDeclarationError {
  NonFinalClassError({required super.trace})
      : super(message: "All fields of a GraphQL class must be final");
}

class InvalidQueryDeclarationError extends GraphQLGeneratorError {
  InvalidQueryDeclarationError({required super.trace, required String message})
      : super(
            message:
                '$message\nAn error occurred while trying to generate the schema for ${trace.last.name}');
}

class DuplicateQueryError extends InvalidQueryDeclarationError {
  DuplicateQueryError({required super.trace})
      : super(message: 'All queries must have a unique name');
}

class InvalidDefaultValueError extends InvalidQueryDeclarationError {
  InvalidDefaultValueError({required super.trace})
      : super(
            message:
                'Default values are only supported for Scalar types or Scalar iterables');
}

class InvalidMutationDeclarationError extends GraphQLGeneratorError {
  InvalidMutationDeclarationError(
      {required super.trace, required String message})
      : super(
            message:
                '$message\nAn error occurred while trying to generate the schema for ${trace.last.name}');
}

class DuplicateMutationError extends InvalidMutationDeclarationError {
  DuplicateMutationError({required super.trace})
      : super(message: 'All queries must have a unique name');
}

class InvalidDefaultValueMutationError extends InvalidMutationDeclarationError {
  InvalidDefaultValueMutationError({required super.trace})
      : super(
            message:
                'Default values are only supported for Scalar types or Scalar iterables');
}

class InvalidElementError extends GraphQLGeneratorError {
  InvalidElementError(
      {required super.trace,
      required Type received,
      required List<Type> allowedTypes,
      required Type registry})
      : super(
            message:
                'An invalid element was passed to the $registry\nexpected: ${allowedTypes}\nreceived: ${received}');
}

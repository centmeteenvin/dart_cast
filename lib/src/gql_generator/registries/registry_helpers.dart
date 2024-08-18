import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:gql/ast.dart' as ast;

import '../exceptions.dart';

extension Nullable on DartType {
  bool get isNonNull => nullabilitySuffix == NullabilitySuffix.none;
}

extension IsScalar on DartType {
  bool get isScalar =>
      isDartCoreInt || isDartCoreBool || isDartCoreDouble || isDartCoreString;

  bool get isScalarIterable {
    if (!isDartCoreList) return false;
    if (!(this is ParameterizedType)) return false;
    return (this as ParameterizedType).typeArguments.first.isScalar;
  }
}

extension DocString on Element {
  ast.StringValueNode? get description => documentationComment == null
      ? null
      : ast.StringValueNode(value: documentationComment!, isBlock: true);
}

extension DefaultValue on ParameterElement {
  ast.ValueNode? defaultValue(List<Element> trace) {
    if (!hasDefaultValue) return null;

    if (!(type.isScalar || type.isScalarIterable)) {
      throw InvalidDefaultValueError(trace: [...trace, this], type: type);
    }

    if (type.isScalar) {
      if (type.isDartCoreInt) {
        return ast.IntValueNode(value: defaultValueCode!);
      }
      if (type.isDartCoreBool) {
        return ast.BooleanValueNode(value: defaultValueCode! == 'true');
      }
      if (type.isDartCoreDouble) {
        return ast.FloatValueNode(value: defaultValueCode!);
      }
      if (type.isDartCoreString) {
        return ast.StringValueNode(value: defaultValueCode!, isBlock: false);
      }
      throw Exception('Illegal state');
    }
    if (type.isScalarIterable) {
      throw UnimplementedError('Default iterable types are not yet supported');
    }
    return null;
  }
}

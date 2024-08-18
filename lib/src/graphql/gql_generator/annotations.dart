/// Functions annotated with [GraphQL] will be picked up by the build_runner.
/// A schema is then generated for this function and all types that are referenced in the function
/// The given function must fulfill some properties to correctly generate otherwise build_runner will
/// throw an error. These depend on the given [operation].
/// You can check this specifications at [Operation]

// coverage:ignore-file

class GraphQL {
  const GraphQL(this.operation);

  final Operation operation;
}

/// All allowed operation for GraphQL generation
enum Operation {
  /// This generates a GraphQL query. A query has a set of inputs and a single return Type.
  /// The inputs can be Scalars or data class objects, but they cannot be array types.
  /// Similarly Custom input Types can contain another custom data type but no lists.
  ///
  /// In contrast, the return type of the query can be a list. This list can hold a scalar or custom data type.
  /// any custom data type referred in the return type will recursively generate another schema definition
  query,

  /// This generate a GraphQL
  mutation;
}

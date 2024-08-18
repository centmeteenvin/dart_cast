/// This exception occurs when the syntax of a given graphQL error is wrong
/// It has nothing to do with a certain schema, just plain syntax checking
class InvalidGraphQlException implements Exception {
  final Exception _sourceSpanException;
  final String request;
  InvalidGraphQlException(this._sourceSpanException, this.request);

  @override
  String toString() {
    return '${_sourceSpanException.toString()}\n$request';
  }
}

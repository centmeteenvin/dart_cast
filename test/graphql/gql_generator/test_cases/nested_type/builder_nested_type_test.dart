import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  test("""
When the generator encounters a type which encounters another non scalar type 
it will generate a a schema for the second type
""", () async {
    final projectDir = await generateTestProject('nested_type');
    final schema = await testEmptyGraphQlOutput(projectDir);
    expect(schema.existsSync(), true);

    validateSchema(schema, 'nested_type', 'nested_type.graphql');
  });
}

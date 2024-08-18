import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  test("""
When the generator encounters a type which encounters another non scalar type 
which holds a reference to the previous type the types will be lazily inferred and generated
""", () async {
    final projectDir = await generateTestProject('recursive_type');
    final schema = await testEmptyGraphQlOutput(projectDir);
    expect(schema.existsSync(), true);

    validateSchema(schema, 'recursive_type', 'recursive_type.graphql');
  });
}

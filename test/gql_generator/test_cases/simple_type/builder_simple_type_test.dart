import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  test('A Scalar type generates a simple schema when found in query', () async {
    final projectDir = await generateTestProject('simple_type');
    final schema = await testEmptyGraphQlOutput(projectDir);
    expect(schema.existsSync(), true);

    validateSchema(schema, 'simple_type', 'simple_type.graphql');
  });
}

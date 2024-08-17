import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  test('a scalar query generates a simple schema', () async {
    final projectDir = await generateTestProject('simple_query');
    final schema = await testEmptyGraphQlOutput(projectDir);

    expect(schema.existsSync(), true);

    validateSchema(schema, 'simple_query', 'simple_query.graphql');
  });
}

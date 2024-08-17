import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  test('an empty file does not generate anything', () async {
    final projectDir = await generateTestProject('empty_case');
    await testEmptyGraphQlOutput(projectDir);
    expect(
        false,
        Directory(path.join(projectDir.path, 'lib/generated/graphQL'))
            .existsSync());
  });
}

import 'dart:developer';
import 'dart:io';

import 'package:gql/language.dart' as lang;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

Future<Directory> generateTestProject(String directoryToInclude) async {
  final temp = await Directory.systemTemp.createTemp('graphql_generator_test');

  // Set up your project structure within the temp directory
  final projectDir = Directory(path.join(temp.path, 'test_project'));
  await projectDir.create();

  await _copyDirectory(_getTestCaseDirectory(directoryToInclude),
      Directory(projectDir.path + '/lib'));

  final pubspec =
      File('test/graphql/gql_generator/test_cases/test.pubspec.yaml')
          .readAsStringSync()
          .replaceFirst("#PLACEHOLDER#", Directory.current.absolute.path);

  File(path.join(projectDir.path, 'pubspec.yaml')).writeAsStringSync(pubspec);
  addTearDown(() => projectDir.delete(recursive: true));

  return projectDir;
}

Future<File> testEmptyGraphQlOutput(Directory projectDir) async {
  final result = await Process.run('dart', 'run build_runner build'.split(' '),
      workingDirectory: projectDir.path);
  log(result.stdout);
  log(result.stderr);
  return File(
      path.join(projectDir.path, 'lib/generated/graphql/schema.graphql'));
}

void validateSchema(
    File actualSchema, String testCaseDir, String validationSchema) {
  final expectedFile = File(
      path.join(_getTestCaseDirectory(testCaseDir).path, validationSchema));

  expect(actualSchema.existsSync(), true,
      reason: 'The schema file we want to validate does not exist');
  expect(expectedFile.existsSync(), true,
      reason: 'The schema file we want to check against does not exist');

  final actualData = actualSchema.readAsStringSync();
  final expectedData = expectedFile.readAsStringSync();

  expect(() => lang.parseString(actualData), returnsNormally,
      reason: 'The schema we want to check is not valid graphql');
  expect(() => lang.parseString(expectedData), returnsNormally,
      reason: 'The schema we want to check against is not valid graphql');

  final actualDataNode = lang.parseString(actualData);
  final expectedDataNode = lang.parseString(expectedData);

  expect(lang.printNode(actualDataNode), lang.printNode(expectedDataNode));
}

Directory _getTestCaseDirectory(String testCaseName) {
  return Directory(path.join(Directory.current.path,
      'test/graphql/gql_generator/test_cases', testCaseName));
}

/// Copies a directory recursively to a new location.
Future<void> _copyDirectory(Directory source, Directory destination) async {
  // Ensure the destination directory exists
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  await for (var entity in source.list(recursive: false, followLinks: false)) {
    if (entity is Directory) {
      // Recursively copy subdirectories
      var newDirectory =
          Directory('${destination.path}/${entity.uri.pathSegments.last}');
      await _copyDirectory(entity, newDirectory);
    } else if (entity is File) {
      // Copy files
      var newFile = File('${destination.path}/${entity.uri.pathSegments.last}');
      await entity.copy(newFile.path);
    }
  }
}

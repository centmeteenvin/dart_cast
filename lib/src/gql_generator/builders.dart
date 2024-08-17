import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generators.dart';

Builder graphQlSchemaBuilder(BuilderOptions options) => LibraryBuilder(
      QuerySchemaGenerator(),
      generatedExtension: '.g.dart',
    );

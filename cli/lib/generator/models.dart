import 'package:supadart/generator/utils.dart';
import 'package:yaml/yaml.dart';

import 'swagger.dart';

String generateModels(DatabaseSwagger swagger, YamlMap? mappings) {
  String code = 'library models;\n';
  code += "export 'client_extension.dart';\n";
  code += "export 'supadart_abstract_class.dart';\n";
  swagger.definitions.forEach((tableName, _) {
    final className = tableNameToClassName(tableName, mappings);
    final fileName = classNameToFileName(className);
    code += "export '$fileName';\n";
  });
  return code;
}

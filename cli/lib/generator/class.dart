import 'package:yaml/yaml.dart';

import 'converter_methods.dart';
import 'dart_class.dart';
import 'format_to_dart_type.dart';
import 'from_json_method.dart';
import 'insert_method.dart';
import 'static_column_names.dart';
import 'swagger.dart';
import 'update_method.dart';
import 'utils.dart';

List<DartClass> generateDartClasses(
    DatabaseSwagger swagger, YamlMap? mappings) {
  List<DartClass> generatedClasses = [];
  // Object entries
  swagger.definitions.forEach((tableName, table) {
    String dartCode = "";

    final columns = table.columns;
    final requiredFields = table.requiredFields;

    final className = tableNameToClassName(tableName, mappings);

    // Class definition
    dartCode += 'class $className implements SupadartClass<$className> {\n';

    // Attributes
    columns.forEach((columnName, columnDetails) {
      final dartType = postgresFormatToDartType(columnDetails.postgresFormat);

      // Add question mark for optional fields (not in "required")
      final isOptional = !requiredFields.contains(columnName);
      dartCode +=
          'final ${dartType.type}${isOptional ? "?" : ""} $columnName;\n';
    });

    // Constructor
    dartCode += '\n const $className({\n';
    columns.forEach((propertyName, _) {
      final isRequired = requiredFields.contains(propertyName);
      dartCode += '${isRequired ? "required this." : "this."}$propertyName,\n';
    });
    dartCode += '});\n\n';

    // Table name
    dartCode += 'static String get table_name => \'$tableName\';\n';

    // Static column names
    dartCode += generateStaticColumnNames(columns);

    // Methods
    dartCode += generateConverterMethod(className);
    dartCode += generateConverterSingleMethod(className);
    dartCode += generateInsertMethod(columns, requiredFields);
    dartCode += generateUpdateMethod(columns);
    dartCode += generateFromJsonMethod(className, columns, requiredFields);

    dartCode += '}\n\n';
    generatedClasses.add(
      DartClass(
        className: className,
        classCode: dartCode,
      ),
    );
  });

  return generatedClasses;
}

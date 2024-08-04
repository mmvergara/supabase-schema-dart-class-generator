import 'dart:io';

import 'package:supabase/supabase.dart';
import 'package:supadart/generator/generator.dart';
import 'package:supadart/generator/swagger.dart';
import 'package:yaml/yaml.dart';

import '../bin/supadart.dart';
import 'boolean_bit_types.dart';
import 'datetime_types.dart';
import 'json_types.dart';
import 'numeric_types.dart';
import 'string_types.dart';
import 'default_values.dart';

void main() async {
  print("Running Supadart Tests");

  String url;
  String anonKey;
  YamlMap? mappings;
  bool isDart;
  bool isSeparated;
  String output;

  final configPath = 'supadart.yaml';
  print('Using config file: $configPath');
  final configFile = File(configPath);
  final configContent = await configFile.readAsString();
  final config = loadYaml(configContent);

  url = config['supabase_url'];
  anonKey = config['supabase_anon_key'];
  isSeparated = config['separated'] ?? false;
  isDart = config['dart'] ?? false;
  output = config['output'] ??
      (isSeparated ? './lib/models/' : './lib/generated_classes.dart');
  mappings = config['mappings'];

  print('URL: $url');
  print('ANON KEY: $anonKey');
  print('Separated: $isSeparated');
  print('Dart: $isDart');
  print('Output: $output');
  print('Mappings: $mappings');
  print('=' * 50);

  final databaseSwagger = await fetchDatabaseSwagger(url, anonKey);
  if (databaseSwagger == null) {
    print("Failed to fetch database swagger");
    return;
  }
  final files = generateModelFiles(databaseSwagger, false, false, mappings);
  await generateAndFormatFiles(files, './test/models/');
  print("\nGenerated Fresh Models from DB");

  final supabase = SupabaseClient(url, anonKey);
  // ========================================
  // STES = Supabase Table Editor Supported (PRIORITIZED)

  // Numeric Types
  await performNumericTypesTest(supabase);

  // JSON Types
  await performJsonTypesTest(supabase);

  // String Types
  await performStringTypesTest(supabase);

  // Date Time Types
  await performDatetimeTypesTest(supabase);

  // Boolean Bit Types
  await performBooleanBitTypesTest(supabase);

  // Test Type Default Values
  await performDefaultValuesTest(supabase);
}

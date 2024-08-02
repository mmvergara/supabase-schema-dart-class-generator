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
  bool isFlutter;
  bool isSeperated;
  String output;

  final configPath = 'pubspec.yaml';
  print('Using config file: $configPath');
  final configFile = File(configPath);
  final configContent = await configFile.readAsString();
  final config = loadYaml(configContent);

  if (config['supadart'] != null) {
    url = config['supadart']['supabase_url'];
    anonKey = config['supadart']['supabase_anon_key'];
    isSeperated = config['supadart']['seperated'] ?? true;
    isFlutter = config['supadart']['flutter'] ?? true;
    output = config['supadart']['output'] ?? './lib/models/';
    mappings = config['supadart']['mappings'];

    print('Supabase URL: $url');
    print('Supabase ANON KEY: $anonKey');
    print('Seperated: $isSeperated');
    print('Flutter: $isFlutter');
    print('Output: $output');
    print('Mappings: $mappings');
    print('=' * 50);
  } else {
    print(
        'Please add "supadart" config in pubspec.yaml or provide config file using --config');
    exit(1);
  }

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

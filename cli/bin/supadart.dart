import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:supadart/generator/generator.dart';
import 'package:supadart/generator/swagger.dart';

const String version = 'v1.3.8';
const String red = '\x1B[31m'; // Red text
const String green = '\x1B[32m'; // Green text
const String blue = '\x1B[34m'; // Blue text
const String reset = '\x1B[0m'; // Reset to default color
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show usage information')
    ..addOption('config',
        abbr: 'c',
        help:
            'Path to config file of yaml            -- (default: "pubspec.yaml")')
    ..addFlag('version', abbr: 'v', negatable: false, help: version);

  final results = parser.parse(arguments);

  if (results['help']) {
    print('Usage: dart script.dart [options]');
    print(parser.usage);
    exit(0);
  }

  if (results['version']) {
    print(version);
    exit(0);
  }

  String url;
  String anonKey;
  YamlMap? mappings;
  bool isFlutter;
  bool isSeparated;
  String output;

  final configPath = results['config'] ?? 'pubspec.yaml';
  print('Using config file: $configPath');
  final configFile = File(configPath);
  final configContent = await configFile.readAsString();
  final config = loadYaml(configContent);

  if (config['supadart'] != null) {
    url = config['supadart']['supabase_url'];
    anonKey = config['supadart']['supabase_anon_key'];
    isSeparated = config['supadart']['separated'] ?? true;
    isFlutter = config['supadart']['flutter'] ?? true;
    output = config['supadart']['output'] ?? './lib/models/';
    mappings = config['supadart']['mappings'];

    print('Supabase URL: $url');
    print('Supabase ANON KEY: $anonKey');
    print('Separated: $isSeparated');
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
    print('Failed to fetch database');
    exit(1);
  }

  final files =
      generateModelFiles(databaseSwagger, isFlutter, isSeparated, mappings);
  await generateAndFormatFiles(files, output);

  print('\n$green 🎉 Done! $reset');
}

Future<void> generateAndFormatFiles(
    List<GeneratedFile> files, String folderPath) async {
  await Future.wait(files.map((file) async {
    final filePath = folderPath + file.fileName;
    final fileToGenerate = File(filePath);

    // Create file if it doesn't exist else overwrite it
    await fileToGenerate.create(recursive: true);
    await fileToGenerate.writeAsString(file.fileContent);

    // Format the file
    await formatCode(filePath);
    stdout.write('$green 🎯 Generated: $filePath $reset');
  }));
}

Future<void> formatCode(String filePath) async {
  try {
    ProcessResult result = await Process.run('dart', ['format', filePath]);
    if (result.exitCode != 0) {
      stdout.write('$red Failed to Format $filePath $reset\n');
    } else {
      stdout.write('$blue Formatted $reset\n');
    }
  } catch (e) {
    print('Failed to format code: $e');
  }
}

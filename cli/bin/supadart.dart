import 'dart:io';
import 'package:args/args.dart';
import 'package:supadart/config_init.dart';
import 'package:yaml/yaml.dart';
import 'package:supadart/generator/generator.dart';
import 'package:supadart/generator/swagger.dart';

const String version = 'v1.3.8';
const String red = '\x1B[31m'; // Red text
const String green = '\x1B[32m'; // Green text
const String blue = '\x1B[34m'; // Blue text
const String reset = '\x1B[0m'; // Reset to default color

void main(List<String> arguments) async {
  final defaultConfigFile = 'supadart.yaml';
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show usage information')
    ..addFlag('init',
        abbr: 'i',
        negatable: false,
        help: 'Initialize config file supadart.yaml ')
    ..addOption('config',
        abbr: 'c',
        help:
            'Path to config file of yaml         --(default: $defaultConfigFile)')
    ..addOption('url',
        abbr: "u",
        help:
            'Supabase URL                        --(default: $defaultConfigFile supabase_url)')
    ..addOption('key',
        abbr: "k",
        help:
            'Supabase ANON KEY                   --(default: $defaultConfigFile supabase_anon_key)')
    ..addOption('output',
        abbr: 'o',
        help:
            'Output file path, add ./ prefix     --(default: ./lib/generated_classes.dart or ./lib/models/ if --separated is enabled')
    ..addFlag('dart',
        abbr: 'd',
        negatable: false,
        help: 'Generation for pure Dart project    --(default: false)')
    ..addFlag('separated',
        abbr: 's',
        negatable: false,
        help: 'Separated files for each classes    --(default: false)')
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

  if (results['init']) {
    await configFileInit(defaultConfigFile);
    exit(0);
  }

  String url;
  String anonKey;
  bool isDart;
  bool isSeparated;
  String output;
  YamlMap? mappings;

  final configPath = results['config'] ?? defaultConfigFile;
  final configFile = File(configPath);
  final configContent = await configFile.readAsString();
  final config = loadYaml(configContent);

  url = results['url'] ?? config['supabase_url'] ?? '';
  anonKey = results['key'] ?? config['supabase_anon_key'] ?? '';
  if (url.isEmpty || anonKey.isEmpty) {
    print(
        "Please provide --url and --key or Set supabase_url and supabase_anon_key in .yaml file");
    print('use -h or --help for help');
    exit(1);
  }

  isSeparated = results['separated'] ? true : config['separated'] ?? false;
  isDart = results['dart'] ? true : config['dart'] ?? false;
  output = results['output'] ??
      config['output'] ??
      (isSeparated ? './lib/models/' : './lib/generated_classes.dart');
  mappings = config['mappings'];

  print('URL: $url');
  print('ANON KEY: $anonKey');
  print('Output: $output');
  print('Separated: $isSeparated');
  print('Dart: $isDart');
  print('Mappings: $mappings');
  print('=' * 50);

  final databaseSwagger = await fetchDatabaseSwagger(url, anonKey);
  if (databaseSwagger == null) {
    print('Failed to fetch database');
    exit(1);
  }

  final files =
      generateModelFiles(databaseSwagger, isDart, isSeparated, mappings);
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

# Supabase Schema Dart Class Generator

This is a simple command line tool that generates dart classes from your Supabase schema.

## Installation

```bash
# 🎯 Active from pub.dev
dart pub global activate supadart
```

```bash
# 🚀 Run via
supadart
# or
dart pub global run supadart
```

## Configuration

Example of `supadart.yaml` file:

```yaml
# Required, your supabase server url
supabase_url: https://xxx.supabase.co
# Required, your supabase anon key
supabase_anon_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional, where to place the generated classes files
output: lib/models/
# Optional, if you want to generate separated files for each classes
separated: true
# Optional, if you are not using Flutter, just normal Dart project
flutter: true
# Optional, used to map table names to class names(case-sensitive)
mappings:
  books: book
  categories: category
  children: child
  people: person
```

## Generate Classes

```bash
# Set the supabase_url and supabase_anon_key in your supadart.yaml file
supadart

# If you have a .yaml file in a different location
supadart -c path/to/.yaml

# If you dont have a .env file specify the Supabase URL and ANON KEY
supadart -u <your-supabase-url> -k <your-supabase-anon-key>

```

## Options

```bash
-h, --help         Show usage information
-i, --init         Initialize config file supadart.yaml
-c, --config       Path to config file of yaml         --(default: supadart.yaml)
-u, --url          Supabase URL                        --(default: supadart.yaml supabase_url)
-k, --key          Supabase ANON KEY                   --(default: supadart.yaml supabase_anon_key)
-o, --output       Output file path, add ./ prefix     --(default: ./lib/generated_classes.dart or ./lib/models/ if --separated is enabled
-d, --dart         Generation for pure Dart project    --(default: false)
-s, --separated    Separated files for each classes    --(default: false)
-v, --version      v1.3.8
```

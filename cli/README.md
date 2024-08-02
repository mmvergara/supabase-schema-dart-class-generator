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

Add `supadart` field to your `pubspec.yaml` file, example:

```yaml
supadart:
  # Required, your supabase server url
  supabase_url: https://xxx.supabase.co
  # Required, your supabase anon key
  supabase_anon_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

  # Optional, where to place the generated classes files
  output: lib/models/
  # Optional, if you want to generate seperate files for each classes
  seperated: true
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
# Set the supabase_url and supabase_anon_key in your pubspec.yaml file
supadart

# If you have a .yaml file in a different location
supadart -c path/to/.yaml

```

## Options

```bash
-h, --help         Show usage information
-c, --config       Path to the .yaml file -- (default: pubspec.yaml)
-v, --version
```

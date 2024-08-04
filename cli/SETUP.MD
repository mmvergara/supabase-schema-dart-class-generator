# Setup

#### Fill Up the supadart.yaml file with the following content

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
dart: true
# Optional, used to map table names to class names(case-sensitive)
mappings:
  books: book
  categories: category
  children: child
  people: person
```

### Install Dependencies

```bash
dart pub get
```

### Compile and Run

```bash
dart compile exe bin/supadart.dart ; ./bin/supadart.exe
```

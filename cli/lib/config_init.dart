import 'dart:io';

configFileInit(String path) async {
  // Create a new file
  File file = new File(path);

  // Check if the file already exists
  if (await file.exists()) {
    // Prompt the user to overwrite the file
    print('Config file already exists. Do you want to overwrite it? (yes/no)');
    final userInput = stdin.readLineSync();
    if (userInput != null &&
        (userInput.toLowerCase() == 'yes' || userInput.toLowerCase() == 'y')) {
      print('Overwriting the file...');
    } else {
      print('File not overwritten.');
      exit(0);
    }
  }

  // Write to the file
  file.writeAsStringSync('''
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
''');

  print('Config file created at $path, please fill the fields');
}

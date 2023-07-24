class DebugPrompts {
  static String filesToFixSystem(String prompt, String files, String errors) =>
      '''
As an AI Flutter developer, your task is to fix errors in a Flutter app. You are provided with the following project files and a list of known errors:

## Project purpose:
$prompt

## Project files: 
$files

## Known errors:
$errors

Do not add any other explanation, only return the required data.

Your goal is to provide the correct code to fix each error. The code should be valid Dart code and comply with the following guidelines:
- Use null safety in the Dart code.

Please provide the necessary code to fix each error in the respective files. Only write valid code for the given file type.
''';

  static String filesToFixUser() =>
      '''Give me a list of files that need to be fixed. and only return a dart list of strings. without any other explanation or code fences.
If there is need to add new files, add the path to the file in the list.

Example output:
["path/to/file", "path/to/file", "path/to/file"]
''';

  static String getFile(String file) =>
      'Now Generate me the file $file to fix the errors.';
}

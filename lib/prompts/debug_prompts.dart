class DebugPrompts {
  static String system(String files, String errors) => '''
As an AI Flutter developer, your task is to fix errors in a Flutter app. You are provided with the following project files and a list of known errors:

## Project files: 
$files

## Known errors:
$errors

Your goal is to provide the correct code to fix each error. The code should be valid Dart code and comply with the following guidelines:
- Use null safety in the Dart code.
- Return the answers as a Dart map for each file with the correct content to fix the error. The map should have the following structure:
{
  "fileName": "lib/main.dart",
  "content": "The correct code to fix the error"
}
- Ensure that every line of code you generate is valid; do not include code fences in your response.
Please provide the necessary code to fix each error in the respective files. Only write valid code for the given file type.
''';

  static String user() => 'Now Generate me the files map to fix the errors';
}

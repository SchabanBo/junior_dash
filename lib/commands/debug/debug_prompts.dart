class DebugPrompts {
  static String checkCode(String prompt, String files) => '''
As an AI Flutter developer, your task is to review the code of a Flutter app and identify any logical missing implementations. Below are the project details:

## Project purpose 
$prompt

## Project files: 
$files

Please only return the file names and line numbers where:
- The code is missing a logical implementation.
- The code will not work as expected.
- There is a TODO comment.
- Feature are not implemented.

Do not provide any code suggestions or additional explanations. If there is nothing found, simply return "Nothing found to fix".
Exempla of valid answer:
- path/to/file - line xx: "name" logic is missing.
- path/to/other/file - line xxx: "other name" logic is missing.
- path/to/other/file - line xxx: "other name" will not working.
''';
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
  - keep the code as simple as possible and don't use any EXTERNAL packages.

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

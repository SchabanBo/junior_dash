class BuildPrompts {
  static String projectName =
      '''You are project manager how will create a name for a project based on  the user description
      The name should be all lowercase, with underscores to separate words, just_like_this.
      Use only basic Latin letters and Arabic digits: [a-z0-9_]. Also, make sure the name is a valid Dart identifier—that it does not start 
      with digits and is not a reserved dart word.
      give only the project name as result and noting else''';

  static String projectStructure(String projectName) =>
      '''You are an AI flutter developer who is trying to write a flutter app that will generate code for the user based on their intent.
        
    When given their intent, create a complete, exhaustive list of filepaths that the user would write to make the flutter app.

Remember that you must obey these things: 
  - Only list the filepaths you would write, and return them as a dart list of strings. 
  - Do not add any other explanation, only return a dart list of strings.
  - Consider that the project name is: $projectName
  - Don't use any EXTERNAL packages.

    Example output:
    ["lib/main.dart", "lib/screens/...", "lib/widgets/..."]
''';

  static String fileContentSystem(
          String prompt, String projectName, List<String> files) =>
      '''
You are an AI flutter developer who is trying to write a flutter app that will generate code for the user based on their intent.

The purpose of the app is: $prompt

The project name is: $projectName

The files we have decided to generate are: $files

Only write valid code for the given filepath and file type, and return only the code.

Do not add any other explanation, only return valid code for that file type.

Make sure to have consistent filenames if you reference other files we are also generating.

Remember that you must obey these things: 
  - The dart code should be null safe, do not forget to add '?' to variables that are not initialized.
  - do not stray from the names of the files and the shared dependencies we have decided on
  - Do not leave any todos, fully implement every feature requested.
  - MOST IMPORTANT OF ALL - consider always the purpose of the app.
  - Always just generating the code.
  - keep the code as simple as possible and don't use any EXTERNAL packages.
    ''';

  static String fileContentUser(String fileName) =>
      '''Now generate only the code for the file $fileName.''';
}

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
    
    only list the filepaths you would write, and return them as a dart list of strings. 
    do not add any other explanation, only return a dart list of strings.
    do not forget to add the pubspec.yaml file the contains the dependencies you would use.

    consider that the project name is: $projectName

    Example output:
    ["lib/main.dart", "pubspec.yaml"]
''';

  static String shredDependencies(
          String prompt, String projectName, List<String> files) =>
      '''You are an AI flutter developer who is trying to write a flutter app that will generate code for the user based on their intent.
        
    the app is: $prompt
    the project name is: $projectName
    the files we have decided to generate are: $files

    Now that we have a list of files, we need to understand what dependencies they share.
    Please name and briefly describe what is shared between the files we are generating, including exported variables, data schemas, id names of every DOM elements that javascript functions will use, message names, and function names.
    Exclusively focus on the names of the shared dependencies, and do not add any other explanation.''';

  static String fileContentSystem(String prompt, String projectName,
          List<String> files, String shredDependencies) =>
      '''
You are an AI flutter developer who is trying to write a flutter app that will generate code for the user based on their intent.
        
    the purpose of the app is: $prompt
    the project name is: $projectName
    the files we have decided to generate are: $files
    the shared dependencies (like filenames and variable names) we have decided on are: $shredDependencies.
    
    only write valid code for the given filepath and file type, and return only the code.
    do not add any other explanation, only return valid code for that file type.
    The dart code should be null safe.
    Make sure to have consistent filenames if you reference other files we are also generating.
    
    Remember that you must obey these things: 
       - do not stray from the names of the files and the shared dependencies we have decided on
       - MOST IMPORTANT OF ALL - consider always the purpose of the app.
       - every line of code you generate must be valid code. Do not include code fences in your response, for example    
          Bad response:
          ```dart 
          print("hello world")
          ``` 
          Good response:
          print("hello world")
    always just generating the code.
    ''';

  static String fileContentUser(String fileName) =>
      '''Now generate only the code for the file $fileName.''';
}

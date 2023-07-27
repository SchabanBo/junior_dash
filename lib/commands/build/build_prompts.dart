class BuildPrompts {
  static String projectName =
      '''You are project manager how will create a name for a project based on  the user description
      The name should be all lowercase, with underscores to separate words, just_like_this.
      Use only basic Latin letters and Arabic digits: [a-z0-9_]. Also, make sure the name is a valid Dart identifier—that it does not start 
      with digits and is not a reserved dart word.
      give only the project name as result and noting else''';

  static String blueprint = '''
You are a software engineer that design and plan building a software for the user in Flutter.

Please provide the required file structure without any additional explanations or descriptions. Each file must include its respective functions and the necessary widgets for the app. Take into consideration the following elements:

- Error Handling: Incorporate mechanisms for handling errors during API calls and possible data-related problems to enhance user experience.
- Navigation: Set up the navigation to manage routing between different screens.
- Widget Interactions: Organize how various widgets communicate with each other. This may involve designing and outlining data flows among components.
- Imports: Adopt relative import for referencing other files within the project.

Your response MUST adhere to the following format (JSON):

``` json
{
    "pubPackages": [
        "package_name",
        "package_name"
    ],
    "files": [
        {
            "name": "file_name",
            "path": "file_path",
            "purpose": "file_purpose",
            "classes": [
                {
                    "name": "class_name",
                    "purpose": "class_purpose",
                    "functions": [
                        {
                            "name": "function_name",
                            "purpose": "function_purpose",
                            "parameters": [
                                {
                                    "name": "parameter_name",
                                    "type": "parameter_type",
                                    "purpose": "parameter_purpose"
                                }
                            ],
                            "return": {
                                "type": "return_type",
                                "purpose": "return_purpose"
                            },
                            "calls": [
                                {
                                    "name": "call_name",
                                    "purpose": "call_purpose"
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}
```
''';

  static String fileContentSystem(String purpose, String blueprint) => '''
You are an software flutter developer who is trying to write a flutter app and generate code for the user based on their intent.

## The purpose of the app is:
$purpose

## the blueprint of the app is:
$blueprint

Only write valid code for the given filepath and file type, and return only the code.

Do not add any other explanation, only return valid code for that file type.

Make sure to have consistent filenames if you reference other files we are also generating.

Remember that you must obey these things: 
  - The dart code should be null safe, do not forget to add '?' to variables that are not initialized.
  - Do not leave any todos, fully implement every feature requested and every needed logic.
  - MOST IMPORTANT OF ALL - consider always the purpose of the app.
  - Always just generating the code.
  - keep the code as simple as possible and don't use any EXTERNAL packages.
''';

  static String fileContentUser(String fileName) =>
      '''Now generate only the code for the file $fileName.''';
}

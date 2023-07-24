import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../helpers/constants.dart';
import '../prompts/build_prompts.dart';
import '../services/api_service.dart';
import '../services/shell_service.dart';
import 'debug_command.dart';

class BuildCommand extends Command {
  BuildCommand() {
    argParser.addOption(
      'file',
      abbr: 'f',
      help:
          'The file to use as prompt. if a prompt is not provided, this is required',
    );
    argParser.addOption(
      'prompt',
      abbr: 'p',
      help: 'The prompt to use. if a file is not provided, this is required',
    );
    argParser.addOption(
      'project-name',
      abbr: 'n',
      help: 'Project name to use, if not given, new one will be generated',
    );
    argParser.addFlag(
      'dry-build',
      abbr: 'd',
      help: 'this will not try to fix the errors if any found',
    );
  }

  late final List<String> files;
  final Map<String, String> project = {};
  late final String projectName;
  late String prompt;
  late final bool dryBuild;

  @override
  String get description => 'Build a flutter project';

  @override
  String get name => 'build';

  @override
  Future<void> run() async {
    await _parseArgs();
    await _createProject();
    await _wrapUp();
    logger.i('App built successfully');
  }

  Future<void> _parseArgs() async {
    final promptFile = argResults?['file'] as String?;
    if (promptFile != null) {
      prompt =
          await File('${Constants.executePath}/$promptFile').readAsString();
    } else {
      final userPrompt = argResults?['prompt'] as String?;
      if (userPrompt == null) throw Exception('No prompt provided');
    }
    if (prompt.startsWith('#')) {
      final lines = prompt.split('\n');
      projectName = lines[0].substring(1).trim();
    } else {
      projectName =
          argResults?['project-name'] as String? ?? await _getProjectName();
    }
    dryBuild = argResults?['dry-build'] as bool? ?? true;
  }

  Future<void> _createProject() async {
    logger.i('Creating project: $projectName');
    await ShellService.run('flutter create $projectName -e');
    Directory.current = '${Directory.current.path}/$projectName';
    files = await _getFilesStructure();
    final chatHistory = <ChatHistory>[];
    chatHistory.add(ChatHistory(
      ChatRole.system,
      BuildPrompts.fileContentSystem(prompt, projectName, files),
    ));
    for (var fileName in files) {
      logger.i('Generating file: $fileName');
      final fileContent = await ApiService().chat(
        history: chatHistory,
        user: BuildPrompts.fileContentUser(fileName),
      );

      logger.d('File name: $fileName \nFile content: $fileContent');
      final filePath = fileName;
      final file = File(filePath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(fileContent);
      project[fileName] = filePath;
    }
  }

  Future<void> _wrapUp() async {
    await File('prompt.md').writeAsString(prompt);
    if (dryBuild) {
      ShellService.run('code .');
      return;
    }

    /// fix the errors
    logger.i('Checking errors');
    await DebugCommand().run();
    ShellService.run('code .');
  }

  Future<String> _getProjectName() async {
    final result =
        await ApiService().chat(system: BuildPrompts.projectName, user: prompt);
    logger.i('Project name: $result');
    return result;
  }

  Future<List<String>> _getFilesStructure() async {
    final fileResponse = await ApiService()
        .chat(system: BuildPrompts.projectStructure(projectName), user: prompt);
    final files = jsonDecode(fileResponse) as List;
    logger.i('Project files Structure:');
    var i = 0;
    for (var file in files) {
      logger.i('${++i}- $file');
    }
    return files.map((e) => e.toString()).toList();
  }
}

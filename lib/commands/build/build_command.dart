import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:junior_dash/commands/build/blueprint_model.dart';
import 'package:junior_dash/services/memory_service.dart';
import 'package:junior_dash/services/project_service.dart';

import '../../helpers/constants.dart';
import '../../services/api_service.dart';
import '../../services/shell_service.dart';
import '../debug/debug_command.dart';
import 'build_prompts.dart';

class BuildCommand extends Command {
  BuildCommand() {
    argParser.addOption(
      'file',
      abbr: 'f',
      help: 'The file that contains the project purpose.',
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

  late final Blueprint blueprint;
  late final bool dryBuild;
  late final String projectName;
  late String purpose;
  late final Project _project;

  @override
  String get description => 'Build a flutter project';

  @override
  String get name => 'build';

  @override
  Future<void> run() async {
    await _parseArgs();
    if (_project.done) {
      logger.i('⚠️ Project already built, skipping build process');
      return;
    } else {
      await _createBlueprint();
      await _addingPackages();
      await _createFiles();
    }
    await _wrapUp();
    logger.i('✅ App built successfully');
  }

  Future<void> _parseArgs() async {
    final name = argResults?['project-name'] as String?;
    final file = argResults?['file'] as String?;
    if (file == null && name == null) {
      throw Exception(
          'You must provide either a file with project purpose or a project name to continue the build process');
    }
    if (file != null) {
      purpose = await File('${Constants.executePath}/$file').readAsString();
      projectName = name ?? await _getProjectName();
      await _createProject();
    } else {
      projectName = name!;
      await _continueProject();
    }
    dryBuild = argResults?['dry-build'] as bool? ?? false;
  }

  Future<void> _createProject() async {
    logger.i('⚒️ Creating project: $projectName');
    await ShellService.run('flutter create $projectName -e');
    _project = await ProjectService().addProject(
      projectName,
      '${Directory.current.path}/$projectName',
    );

    Directory.current = _project.path;
    MemoryService.set(MemoryKeys.projectPurpose, purpose);
    logger.i('⚒️ Project created successfully');
  }

  Future<void> _continueProject() async {
    final project = await ProjectService().getProject(projectName);
    if (project == null) {
      throw Exception('Project with the name $projectName does not exist');
    }
    _project = project;
    Directory.current = project.path;
    purpose = await MemoryService.get(MemoryKeys.projectPurpose);
    logger.i('⚒️ Continuing project: $projectName');
  }

  Future<void> _wrapUp() async {
    if (dryBuild) return;

    /// fix the errors
    logger.i('🔍 Checking errors');
    await DebugCommand().run();
  }

  Future<String> _getProjectName() async {
    final result = await ApiService()
        .chat(system: BuildPrompts.projectName, user: purpose);
    logger.i('Project name: $result');
    return result;
  }

  Future<void> _createBlueprint() async {
    logger.i('💭 Creating blueprint');
    final blueprintStr = await MemoryService.get(MemoryKeys.blueprint);
    if (blueprintStr.isNotEmpty) {
      logger.i('💭 Blueprint already exists, skipping creation');
      blueprint = Blueprint.fromJson(blueprintStr);
    } else {
      final response = await ApiService().chat(
        system: BuildPrompts.blueprint,
        user: 'The App purpose is:\n $purpose',
      );
      logger.d('Blueprint response: $response');
      blueprint = Blueprint.fromJson(response);
      await MemoryService.set(MemoryKeys.blueprint, blueprint.toJson());
      logger.i('💭 Blueprint created successfully');
    }
    logger.d('Blueprint: ${blueprint.toMarkdown()}');
  }

  Future<void> _createFiles() async {
    final system =
        BuildPrompts.fileContentSystem(purpose, blueprint.toMarkdown());
    for (var fileToGenerate in blueprint.files) {
      if (fileToGenerate.isGenerated) continue;
      logger.i('⌨️ Generating file: ${fileToGenerate.name}');
      final fileContent = await ApiService().chat(
        system: system,
        user: BuildPrompts.fileContentUser(fileToGenerate.name),
      );

      logger.d('File content:\n$fileContent');
      final filePath = fileToGenerate.path;
      final file = File(filePath);
      if (!await file.exists()) await file.create(recursive: true);
      await file.writeAsString(fileContent);
      fileToGenerate.isGenerated = true;
      await MemoryService.set(MemoryKeys.blueprint, blueprint.toJson());
    }
    ProjectService().setProjectDone(projectName);
  }

  Future<void> _addingPackages() async {
    final packagesToIgnore = ['flutter', 'flutter_test'];
    for (var package in blueprint.pubPackages) {
      if (packagesToIgnore.contains(package)) continue;
      logger.i('📦 Adding package: $package');
      await ShellService.run('flutter pub add $package');
    }
  }
}

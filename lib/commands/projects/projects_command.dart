import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../../helpers/constants.dart';
import '../../services/project_service.dart';

class ProjectsCommand extends Command {
  @override
  String get description => 'Manage your projects';

  @override
  String get name => 'projects';

  ProjectsCommand() {
    argParser.addCommand(
      'list',
    );
    argParser.addCommand(
        'remove',
        ArgParser()
          ..addFlag(
            'name',
            abbr: 'n',
            help: 'project name to remove',
          ));
  }

  final _projectService = ProjectService();

  @override
  Future<void> run() async {
    if (argResults?.command?.name == 'list') {
      await _listProjects();
    } else if (argResults?.command?.name == 'remove') {
      await _removeProject();
    }
  }

  Future<void> _listProjects() async {
    final projects = await _projectService.getProjects();
    if (projects.isEmpty) {
      logger.i('No projects found');
      return;
    }
    logger.i('Projects:');
    for (final project in projects) {
      logger.i('${project.name} - ${project.path}');
    }
  }

  Future<void> _removeProject() async {
    final name = argResults?.command?['name'] as String?;
    if (name == null) {
      throw Exception('You must provide a project name to remove');
    }
    await _projectService.removeProject(name);
    logger.i('Project $name removed successfully');
  }
}

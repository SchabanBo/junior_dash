import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:junior_dash/commands/debug/debug_command.dart';
import 'package:junior_dash/commands/projects/projects_command.dart';
import 'package:junior_dash/services/api_service.dart';
import 'package:junior_dash/services/env_service.dart';
import 'package:junior_dash/services/logger_servicer.dart';

import 'commands/build/build_command.dart';
import 'helpers/constants.dart';

class JuniorDash {
  Future<void> run(List<String> arguments) async {
    final timer = Stopwatch()..start();
    final runner = CommandRunner('gpt', 'test')
      ..addCommand(ProjectsCommand())
      ..addCommand(BuildCommand())
      ..addCommand(DebugCommand())
      ..argParser.addFlag('verbose', abbr: 'v', help: 'Prints all logs');

    await EnvService().readEnv();
    await _ensureBaseDirectory();
    final args = runner.argParser.parse(arguments);
    final isVerbose = args['verbose'] as bool? ?? false;
    await LoggingService().createLogger(isVerbose);

    logger.i('Starting junior dash');
    await runner.runCommand(args);
    logger.i('Used tokens: ${ApiService.usedToken}');
    logger.i('Junior dash Finished in ${timer.elapsed}');
    if (EnvService.finishCommand.isNotEmpty) {
      logger.i('Running finish command ${EnvService.finishCommand}');
      Process.run(EnvService.finishCommand, [], runInShell: true);
    }
  }

  Future<void> _ensureBaseDirectory() async {
    final baseDirectory = Directory(EnvService.workingDirectory);
    if (!await baseDirectory.exists()) {
      await baseDirectory.create(recursive: true);
    }
    Constants.executePath = Directory.current.path;
    Directory.current = EnvService.workingDirectory;
  }
}

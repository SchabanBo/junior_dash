import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:gpt/commands/build_command.dart';
import 'package:gpt/helpers/constants.dart';
import 'package:gpt/services/env_service.dart';
import 'package:gpt/services/logger_servicer.dart';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner('gpt', 'test')
    ..addCommand(BuildCommand())
    ..argParser.addFlag('verbose', abbr: 'v', help: 'Prints all logs');

  await EnvService().readEnv();
  await _ensureBaseDirectory();
  final args = runner.argParser.parse(arguments);
  final isVerbose = args['verbose'] as bool? ?? false;
  await LoggingService().createLogger(isVerbose);
  logger.i('Starting the app');

  await runner.runCommand(args);
}

Future<void> _ensureBaseDirectory() async {
  final baseDirectory = Directory(workingDirectory);
  if (!await baseDirectory.exists()) {
    await baseDirectory.create(recursive: true);
  }
  Constants.executePath = Directory.current.path;
  Directory.current = workingDirectory;
}

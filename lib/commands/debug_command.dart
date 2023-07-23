import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../helpers/constants.dart';
import '../services/shell_service.dart';

class DebugCommand extends Command {
  String? errorsFile;
  DebugCommand({this.errorsFile}) {
    argParser.addOption(
      'errors',
      abbr: 'e',
      help: 'The file to use as known errors. every line is an error',
    );
  }

  @override
  String get description => 'Debug a flutter project for errors and fix them';

  @override
  String get name => 'debug';

  @override
  FutureOr run() async {
    await _parseArgs();
    await _runAnalyze();
  }

  Future<void> _parseArgs() async {
    errorsFile ??= argResults?['errors'] as String?;
  }

  Future<void> _runAnalyze() async {
    final result = await ShellService.run('flutter pub get');
    final analyzerResult = await ShellService.run('flutter analyze');
    result.combine(analyzerResult);
    if (!result.hasErrors) {
      ShellService.run('code .');
      return;
    }
    logger.e('Analyzing app result : $result');

    /// write the errors to a file
    final errorsFile = File('errors.md');
    await errorsFile.writeAsString(result.toFile());
  }
}

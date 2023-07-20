import 'dart:async';

import 'package:args/command_runner.dart';

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
  FutureOr run() async {}

  Future<void> _parseArgs() async {
    errorsFile ??= argResults?['errors'] as String?;
  }

  Future<void> _runPubGet() async {
    final errors = await ShellService.run('flutter pub get');
  }
}

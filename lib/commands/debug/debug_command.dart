import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:junior_dash/commands/debug/debug_prompts.dart';
import 'package:junior_dash/helpers/directory_extension.dart';
import 'package:junior_dash/helpers/list_extension.dart';
import 'package:junior_dash/helpers/string_extension.dart';
import 'package:junior_dash/services/api_service.dart';

import '../../helpers/constants.dart';
import '../../services/shell_service.dart';

const _debugFile = 'debug.md';

class DebugCommand extends Command {
  DebugCommand() {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'The path to the project to debug',
    );
  }

  @override
  String get description => 'Debug a flutter project for errors and fix them';

  @override
  String get name => 'debug';

  @override
  FutureOr run() async {
    await _parseArgs();
    var index = 0;
    while (await _runAnalyze() && index < 10) {
      logger.i('⚒️ Fixing errors for the $index time');
      await _fix();
      index++;
    }

    if (index == 10) {
      logger.e('❌ Could not fix all errors');
    } else {
      logger.i('✅ No more errors found');
    }
  }

  Future<void> _parseArgs() async {
    final path = argResults?['path'] as String?;
    if (path != null) {
      if (!await Directory(path).exists()) {
        logger.e('The path $path does not exist');
        exit(1);
      }
      Directory.current = path;
    }
  }

  Future<bool> _runAnalyze() async {
    final hasErrors =
        await File(_debugFile).exists() && await File(_debugFile).length() > 0;
    if (hasErrors) return true;

    logger.i('🔍 Running analyze');
    await ShellService.run('dart fix --apply');
    await ShellService.run('flutter analyze --pub --write=$_debugFile');

    /// remove the info from the error.md file
    final errorFile = File(_debugFile);
    final lines = await errorFile.readAsLines();
    final errors = <String>[];
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].startsWith('[error]')) continue;
      final error = lines[i].replaceFirst('[error]', '').trim();
      errors.add('$error.');
      i++;
    }
    var debugResult = errors.toMarkdownList();
    debugResult += await _checkMissingImplementations();
    debugResult = debugResult.trim();
    await errorFile.writeAsString(debugResult);
    if (debugResult.isEmpty) return false;

    logger.i('🪲 ${errors.length} errors found');
    logger.i(errors.toMarkdownList());
    return true;
  }

  Future<String> _checkMissingImplementations() async {
    final files = await Directory('lib').readDartFilesRecursively();
    final prompt = await File('prompt.md').readAsString();
    final response = await ApiService().chat(
      system: DebugPrompts.checkCode(prompt, files.join()),
      user: 'Check missing implementations',
    );
    logger.i('💭 Missing implementations:\n $response');
    if (response.contains('Nothing found to fix')) return '';
    return '\n## Missing implementations\n$response';
  }

  Future<void> _fix() async {
    final files = await Directory('lib').readDartFilesRecursively();
    final prompt = await File('prompt.md').readAsString();
    final errors = await File(_debugFile).readAsString();
    final history = <ChatHistory>[];
    final response = await ApiService().chat(
      system: DebugPrompts.filesToFixSystem(prompt, files.join(), errors),
      user: DebugPrompts.filesToFixUser(),
      history: history,
    );
    final filesToFix = response.toList();
    logger.i('⚒️ Files to fix:\n${filesToFix.toMarkdownList()}');
    for (final file in filesToFix) {
      final response = await ApiService().chat(
        user: DebugPrompts.getFile(file as String),
        history: history,
      );
      logger.i('⚒️ Fixing $file');
      logger.v('Correct code $response');
      await File(file).writeAsString(response);
    }

    /// empty the error file
    await File(_debugFile).writeAsString('');
  }
}

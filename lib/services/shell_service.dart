import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../helpers/constants.dart';

class ShellService {
  static Future<ShellCommandResult> run(String command) async {
    logger.d('Running command: $command');
    final process = await Process.start('cmd.exe', ['/c', command]);
    final output = <String>[];
    process.stdout.transform(utf8.decoder).listen((data) {
      logger.d(data);
      output.add(data);
    });
    final errors = <String>[];
    process.stderr.transform(utf8.decoder).listen((data) {
      logger.e(data);
      errors.add(data);
    });

    final exitCode = await process.exitCode;
    logger.d('Exit code: $exitCode');
    return ShellCommandResult(output, errors)..exitCode = exitCode;
  }
}

class ShellCommandResult {
  int exitCode = 0;
  final List<String> output;
  final List<String> errors;
  ShellCommandResult(this.output, this.errors);

  bool get hasErrors => exitCode != 0;

  void combine(ShellCommandResult other) {
    exitCode = max(exitCode, other.exitCode);
    output.addAll(other.output);
    errors.addAll(other.errors);
  }

  String toFile() {
    final buffer = StringBuffer();
    buffer.writeln(output.join('\n - '));
    return buffer.toString();
  }
}

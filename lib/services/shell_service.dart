import 'dart:convert';
import 'dart:io';

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
    return ShellCommandResult(output, errors);
  }
}

class ShellCommandResult {
  final List<String> output;
  final List<String> errors;
  ShellCommandResult(this.output, this.errors);

  bool get hasErrors => errors.isNotEmpty;

  void combine(ShellCommandResult other) {
    output.addAll(other.output);
    errors.addAll(other.errors);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Output:');
    buffer.writeln(output.join('\n - '));
    buffer.writeln('Errors:');
    buffer.writeln(errors.join('\n - '));
    return buffer.toString();
  }
}

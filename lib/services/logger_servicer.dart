import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:junior_dash/helpers/int_extension.dart';
import 'package:logger/logger.dart';

import '../helpers/constants.dart';
import 'env_service.dart';

class LoggingService {
  Future<void> createLogger(bool isVerbose) async {
    logger = Logger(
      filter: ProductionFilter(),
      printer: _MyPrinter(),
      output: MultiOutput([
        _ConsoleLogOutput(isVerbose ? Level.verbose : Level.info),
        await _createFileLogOutput(),
      ]),
    );
  }

  Future<_FileLogOutput> _createFileLogOutput() async {
    final logDirectory = _getLogsDirectoryPath();
    final directory = Directory(logDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final now = DateTime.now();
    var index = 0;
    final baseName =
        'log_${now.year}${now.month.towDigits()}${now.day.towDigits()}';
    var fileName = '$logDirectory/${baseName}_$index.log';
    var file = File(fileName);
    while (await file.exists()) {
      index++;
      fileName = '$logDirectory/${baseName}_$index.log';
      file = File(fileName);
    }
    await file.create();
    return _FileLogOutput(file);
  }

  String _getLogsDirectoryPath() => '${EnvService.workingDirectory}/logs';

  /// Deletes all log files older than 7 days
  Future<void> cleanupLogs() async {
    final directoryPath = _getLogsDirectoryPath();
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      final now = DateTime.now();
      final files = await directory.list().toList();
      for (final file in files) {
        final fileStat = await file.stat();
        final fileAge = now.difference(fileStat.modified);
        if (fileAge.inDays > 7) {
          await file.delete();
          logger.i('Deleted log file ${file.path}');
        }
      }
    }
  }
}

class _FileLogOutput extends LogOutput {
  final File logFile;

  _FileLogOutput(this.logFile);
  @override
  void output(OutputEvent event) {
    logFile.writeAsStringSync(
      '${event.lines.join('\n')}\n',
      mode: FileMode.append,
    );
  }
}

class _MyPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var message = event.message;
    var error = event.error;
    var stackTrace = event.stackTrace;
    var level = event.level;

    var emoji = PrettyPrinter.levelEmojis[level];
    var builder = StringBuffer();
    const spacer = '|';
    builder.write(_getTime());
    builder.write(spacer);
    builder.write(emoji);
    builder.write(_logLevel(level));
    builder.write(spacer);
    builder.write(_getLogLocation());
    builder.write(spacer);
    builder.write(message);

    var errorString = error.toString();
    if (errorString != 'null') {
      var errorLines = errorString.split('\n');
      errorLines = errorLines.map((line) => '  $line').toList();
      builder.write('\n${errorLines.join('\n')}');
      builder.write('\n');
    }

    var stackTraceString = stackTrace.toString();
    if (stackTraceString != 'null') {
      var stackTraceLines = stackTraceString.split('\n');
      stackTraceLines = stackTraceLines.map((line) => '  $line').toList();
      builder.write('\n${stackTraceLines.join('\n')}');
    }

    return [builder.toString()];
  }

  String _logLevel(Level level) {
    return level.name.substring(0, 3).toUpperCase();
  }

  String _getLogLocation() {
    final stack = StackTrace.current.toString().split('\n');
    final line = stack[4];
    return line.substring(
      line.lastIndexOf('/') + 1,
      line.indexOf('.dart'),
    );
  }

  String _getTime() {
    var now = DateTime.now().toUtc();
    var h = now.hour.towDigits();
    var min = now.minute.towDigits();
    var sec = now.second.towDigits();
    var ms = now.millisecond.threeDigits();
    return '$h:$min:$sec.$ms';
  }
}

class _ConsoleLogOutput extends LogOutput {
  final Level level;
  late Timer loadingTimer;
  int loadingIndex = 0;
  final loadingIndicators = ['💭', '🔍', '⚒️', '🪲', '⌨️', '🖱️'];
  _ConsoleLogOutput(this.level) {
    startLoading();
  }

  @override
  void output(OutputEvent event) {
    if (event.level.index < level.index) return;
    loadingTimer.cancel();
    stdout.write('\r');
    for (var line in event.lines) {
      line = line.substring(21);
      final i = line.indexOf('|');
      line = line.substring(i + 1);
      stdout.writeln(line);
    }
    startLoading();
  }

  void startLoading() {
    loadingTimer = Timer.periodic(Duration(milliseconds: 400), (_) {
      _updateLoadingIndicator();
    });
  }

  final _random = Random();
  void _updateLoadingIndicator() {
    stdout.write('\r${loadingIndicators[loadingIndex]} Working');
    loadingIndex = _random.nextInt(loadingIndicators.length);
  }
}

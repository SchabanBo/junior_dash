import 'dart:io';

const String _memoryPath = 'dash_memory';

class MemoryService {
  static String path(MemoryKeys key) => '$_memoryPath/${key.name}.${key.type}';

  static Future<void> _ensureDirectoryExist() async {
    final dir = Directory(_memoryPath);
    if (!await dir.exists()) await dir.create();
  }

  static Future<void> set(MemoryKeys key, String value) async {
    await _ensureDirectoryExist();
    final file = File(path(key));
    if (!await file.exists()) await file.create();
    await file.writeAsString(value);
  }

  static Future<String> get<T>(MemoryKeys key) async {
    await _ensureDirectoryExist();
    final file = File(path(key));
    if (!await file.exists()) return '';
    return await file.readAsString();
  }
}

enum MemoryKeys {
  blueprint._('blueprint', 'json'),
  projectPurpose._('projectPurpose', 'md'),
  debug._('debug', 'md');

  final String name;
  final String type;

  const MemoryKeys._(this.name, this.type);
}

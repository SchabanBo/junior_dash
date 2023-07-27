import 'dart:convert';

extension NullStringExtension on String? {
  bool get isNotEmptyOrNull => this != null && this!.isNotEmpty;

  bool get isEmptyOrNull => this == null || this!.isEmpty;
}

extension StringExtension on String {
  String cleanCodeFences() {
    final lines = split('\n');
    final result = <String>[];
    for (var line in lines) {
      if (!line.startsWith('```')) {
        result.add(line);
      }
    }
    return result.join('\n');
  }

  String ensureValidList() {
    if (startsWith('[') && endsWith(']')) return this;
    return '[$this]';
  }

  String ensureValidSPath() {
    return replaceAll('\\', '/');
  }

  List toList() {
    return jsonDecode(ensureValidSPath().ensureValidList()) as List;
  }
}

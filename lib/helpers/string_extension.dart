import 'dart:convert';

extension StringExtension on String {
  String cleanCodeFences() {
    if (!startsWith('```')) return this;
    return split('\n').sublist(1, split('\n').length - 1).join('\n');
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

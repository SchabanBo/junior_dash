extension StringExtension on String {
  String cleanCodeFences() {
    if (!startsWith('```')) return this;
    return split('\n').sublist(1, split('\n').length - 1).join('\n');
  }
}

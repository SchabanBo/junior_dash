extension ListExtension<T> on List<T> {
  String toMarkdownList() {
    final result = StringBuffer();
    for (var item in this) {
      result.writeln('- $item');
    }
    return result.toString();
  }
}

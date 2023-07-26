import 'dart:io';

extension DirectoryExtension on Directory {
  Future<List<ProjectFile>> readDartFilesRecursively() async {
    final dartFiles = <ProjectFile>[];
    if (!await exists()) return dartFiles;

    final files = await list(recursive: true).toList();
    for (var file in files) {
      if (file is File) {
        if (file.path.endsWith('.dart')) {
          final content = await file.readAsString();
          dartFiles.add(ProjectFile(file.path, content));
        }
      }
    }

    return dartFiles;
  }
}

class ProjectFile {
  final String path;
  final String content;

  const ProjectFile(this.path, this.content);

  @override
  String toString() {
    return '''### $path\n\n ```dart \n$content \n```\n''';
  }
}

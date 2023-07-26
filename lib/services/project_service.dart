import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:junior_dash/services/env_service.dart';

class ProjectService {
  late final String _path =
      '${EnvService.workingDirectory}/dash_memory/projects.json';

  Future<File> _getFile() async {
    final file = File(_path);
    if (!await file.exists()) await file.create(recursive: true);
    return file;
  }

  Future<void> _writeProjects(List<Project> projects) async {
    final file = await _getFile();
    await file
        .writeAsString(jsonEncode(projects.map((e) => e.toMap()).toList()));
  }

  Future<List<Project>> getProjects() async {
    final file = await _getFile();
    final projectsStr = await file.readAsString();
    if (projectsStr.isEmpty) return [];
    final projects = jsonDecode(projectsStr) as List<dynamic>;
    return projects.map((e) => Project.fromMap(e)).toList();
  }

  Future<Project> addProject(String name, String path) async {
    final projects = await getProjects();
    if (projects.any((element) => element.name == name)) {
      throw Exception('Project with the same name already exists');
    }
    final project = Project(name: name, path: path, done: false);
    projects.add(project);
    await _writeProjects(projects);
    return project;
  }

  Future<void> setProjectDone(String name) async {
    final projects = await getProjects();
    final index = projects.indexWhere((element) => element.name == name);
    projects[index] = projects[index].copyWith(done: true);
    await _writeProjects(projects);
  }

  Future<Project?> getProject(String name) async {
    final projects = await getProjects();
    return projects.firstWhereOrNull((element) => element.name == name);
  }

  Future<void> removeProject(String name) async {
    final projects = await getProjects();
    final index = projects.indexWhere((element) => element.name == name);
    projects.removeAt(index);
    await _writeProjects(projects);
  }
}

class Project {
  final String name;
  final String path;
  final bool done;

  Project({
    required this.name,
    required this.path,
    required this.done,
  });

  Project.fromMap(Map<String, dynamic> json)
      : name = json['name'] as String,
        path = json['path'] as String,
        done = json['done'] as bool;

  Project copyWith({
    String? name,
    String? path,
    bool? done,
  }) {
    return Project(
      name: name ?? this.name,
      path: path ?? this.path,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'done': done,
    };
  }
}

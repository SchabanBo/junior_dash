import 'dart:convert';

class Blueprint {
  final List<String> pubPackages;
  final List<BlueprintFile> files;

  Blueprint({required this.pubPackages, required this.files});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'pubPackages': pubPackages});
    result.addAll({'files': files.map((x) => x.toMap()).toList()});

    return result;
  }

  factory Blueprint.fromMap(Map<String, dynamic> map) {
    return Blueprint(
      pubPackages: List<String>.from(map['pubPackages'] ?? []),
      files: List<BlueprintFile>.from(
          map['files']?.map((x) => BlueprintFile.fromMap(x))),
    );
  }

  String toMarkdown() {
    final StringBuffer markdown = StringBuffer();

    void addHeader(String headerText, int level) {
      markdown.writeln('${'#' * (level + 2)} $headerText');
      markdown.writeln();
    }

    void addListItem(String itemText) {
      markdown.writeln('- $itemText');
    }

    void addDivider() {
      markdown.writeln('---');
      markdown.writeln();
    }

    addHeader('Package:', 1);
    for (final package in pubPackages) {
      addListItem(package);
    }

    for (final file in files) {
      addHeader('File: ${file.name}', 2);
      addListItem('Path: ${file.path}');
      addListItem('Purpose: ${file.purpose}');

      if (file.imports.isNotEmpty) {
        addHeader('Imports', 3);
        for (final import in file.imports) {
          addListItem('${import.name}: ${import.purpose}');
        }
      }

      if (file.classes.isNotEmpty) {
        addHeader('Classes', 3);
        for (final blueprintClass in file.classes) {
          addHeader('Class: ${blueprintClass.name}', 4);
          addListItem('Purpose: ${blueprintClass.purpose}');

          if (blueprintClass.functions.isNotEmpty) {
            addHeader('Functions', 5);
            for (final function in blueprintClass.functions) {
              addHeader('Function: ${function.name}', 6);
              addListItem('Purpose: ${function.purpose}');

              if (function.parameters.isNotEmpty) {
                addHeader('Parameters', 7);
                for (final parameter in function.parameters) {
                  addListItem(
                      '${parameter.name}: ${parameter.type} - ${parameter.purpose}');
                }
              }

              addHeader('Return', 7);
              addListItem(
                  '${function.returnData.type}: ${function.returnData.purpose}');

              if (function.calls.isNotEmpty) {
                addHeader('Calls', 7);
                for (final call in function.calls) {
                  addListItem('${call.name}: ${call.purpose}');
                }
              }
            }
          }
        }
      }

      addDivider();
    }

    return markdown.toString();
  }

  factory Blueprint.fromJson(String source) =>
      Blueprint.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}

class BlueprintFile {
  final String name;
  final String path;
  final String purpose;
  final List<BlueprintImport> imports;
  final List<BlueprintClass> classes;
  bool isGenerated;

  BlueprintFile({
    required this.name,
    required this.path,
    required this.purpose,
    required this.imports,
    required this.classes,
    this.isGenerated = false,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'path': path});
    result.addAll({'purpose': purpose});
    result.addAll({'imports': imports.map((x) => x.toMap()).toList()});
    result.addAll({'classes': classes.map((x) => x.toMap()).toList()});
    result.addAll({'isGenerated': isGenerated});

    return result;
  }

  factory BlueprintFile.fromMap(Map<String, dynamic> map) {
    return BlueprintFile(
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      purpose: map['purpose'] ?? '',
      imports: List<BlueprintImport>.from(
        map['imports']?.map((x) => BlueprintImport.fromMap(x)),
      ),
      classes: List<BlueprintClass>.from(
        map['classes']?.map((x) => BlueprintClass.fromMap(x)),
      ),
      isGenerated: map['isGenerated'] ?? false,
    );
  }
}

class BlueprintImport {
  final String name;
  final String purpose;

  BlueprintImport({required this.name, required this.purpose});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'purpose': purpose});

    return result;
  }

  factory BlueprintImport.fromMap(Map<String, dynamic> map) {
    return BlueprintImport(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}

class BlueprintClass {
  final String name;
  final String purpose;
  final List<BlueprintFunction> functions;

  BlueprintClass({
    required this.name,
    required this.purpose,
    required this.functions,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'purpose': purpose});
    result.addAll({'functions': functions.map((x) => x.toMap()).toList()});

    return result;
  }

  factory BlueprintClass.fromMap(Map<String, dynamic> map) {
    return BlueprintClass(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      functions: List<BlueprintFunction>.from(
          map['functions']?.map((x) => BlueprintFunction.fromMap(x)) ?? []),
    );
  }
}

class BlueprintFunction {
  final String name;
  final String purpose;
  final List<BlueprintParameter> parameters;
  final BlueprintReturn returnData;
  final List<BlueprintCall> calls;

  BlueprintFunction({
    required this.name,
    required this.purpose,
    required this.parameters,
    required this.returnData,
    required this.calls,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'purpose': purpose});
    result.addAll({'parameters': parameters.map((x) => x.toMap()).toList()});
    result.addAll({'return': returnData.toMap()});
    result.addAll({'calls': calls.map((x) => x.toMap()).toList()});

    return result;
  }

  factory BlueprintFunction.fromMap(Map<String, dynamic> map) {
    return BlueprintFunction(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      parameters: List<BlueprintParameter>.from(
          map['parameters']?.map((x) => BlueprintParameter.fromMap(x)) ?? []),
      returnData: BlueprintReturn.fromMap(map['return']),
      calls: List<BlueprintCall>.from(
          map['calls']?.map((x) => BlueprintCall.fromMap(x)) ?? []),
    );
  }
}

class BlueprintParameter {
  final String name;
  final String type;
  final String purpose;

  BlueprintParameter(
      {required this.name, required this.type, required this.purpose});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'type': type});
    result.addAll({'purpose': purpose});

    return result;
  }

  factory BlueprintParameter.fromMap(Map<String, dynamic> map) {
    return BlueprintParameter(
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}

class BlueprintReturn {
  final String type;
  final String purpose;

  BlueprintReturn({required this.type, required this.purpose});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'type': type});
    result.addAll({'purpose': purpose});

    return result;
  }

  factory BlueprintReturn.fromMap(Map<String, dynamic> map) {
    return BlueprintReturn(
      type: map['type'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}

class BlueprintCall {
  final String name;
  final String purpose;

  BlueprintCall({required this.name, required this.purpose});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'purpose': purpose});

    return result;
  }

  factory BlueprintCall.fromMap(Map<String, dynamic> map) {
    return BlueprintCall(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}

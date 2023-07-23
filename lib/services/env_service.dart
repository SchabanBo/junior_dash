import 'dart:io';

class EnvService {
  static late final String openAIApiKey;
  static late final String workingDirectory;

  Future<void> readEnv() async {
    final envFile = File('.env');
    if (!await envFile.exists()) throw Exception('No .env file found');
    final envContent = await envFile.readAsString();
    final envLines = envContent.split('\n');
    openAIApiKey = _getValue(envLines, 'OPENAI_API_KEY');
    workingDirectory = _getValue(envLines, 'WORKSPACE_DIR');
  }

  String _getValue(List<String> lines, String key) {
    final line = lines.firstWhere((element) => element.startsWith(key));
    final value = line.split('=')[1];
    return value.replaceAll('\r', '').trim();
  }
}

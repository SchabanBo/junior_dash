import 'dart:io';

class EnvService {
  static late final String openAIApiKey;
  static late final String workingDirectory;
  static late final String gptModel;
  static late final String gtpModelBig;
  static late final String finishCommand;

  Future<void> readEnv() async {
    final envFile = File('.env');
    if (!await envFile.exists()) throw Exception('No .env file found');
    final envContent = await envFile.readAsString();
    final envLines = envContent.split('\n');
    openAIApiKey = _getValue(envLines, 'OPENAI_API_KEY');
    workingDirectory = _getValue(envLines, 'WORKSPACE_DIR');
    gptModel = _getValue(envLines, 'GPT_MODEL');
    gtpModelBig = _getValue(envLines, 'GPT_MODEL_BIG');
    finishCommand = _getValue(envLines, 'FINISH_COMMAND');
  }

  String _getValue(List<String> lines, String key) {
    final line = lines.firstWhere((element) => element.startsWith(key));
    final value = line.split('=')[1];
    return value.replaceAll('\r', '').trim();
  }
}

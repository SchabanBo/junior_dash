import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:junior_dash/helpers/string_extension.dart';

import '../helpers/constants.dart';
import 'env_service.dart';

class ApiService {
  static num usedToken = 0;
  Future<String> chat({
    String? system,
    required String user,
    List<ChatHistory>? history,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${EnvService.openAIApiKey}'
    };
    logger.d('Chatting with GPT');
    logger.v('System: $system');
    logger.v('User: $user');
    final timer = Stopwatch()..start();
    history ??= [];
    if (system != null) {
      history.add(ChatHistory(ChatRole.system, system));
    }
    history.add(ChatHistory(ChatRole.user, user));
    final messages = history.map((e) => e.toMap()).toList();
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: headers,
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages,
      }),
    );
    timer.stop();
    logger.d(
        'Chat took ${timer.elapsedMilliseconds} ms with status code ${response.statusCode}');
    logger.v('Response: ${response.body}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['choices'][0]['message']['content'];
      history.add(ChatHistory(ChatRole.assistant, content));
      usedToken += body['usage']['total_tokens'];
      return content.toString().cleanCodeFences();
    } else {
      logger.e('Error: ${response.body}');
      logger.d('Request: ${jsonEncode({"messages": messages})}');
      throw Exception('Failed to chat with GPT');
    }
  }
}

class ChatHistory {
  final ChatRole role;
  final String content;
  ChatHistory(this.role, this.content);

  Map<String, dynamic> toMap() {
    return {
      'role': role.name,
      'content': content,
    };
  }
}

enum ChatRole { system, user, assistant }

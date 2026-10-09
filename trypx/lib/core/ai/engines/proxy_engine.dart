library;

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ai_engine.dart';
import '../ai_exception.dart';
import '../util/json_extractor.dart';

class ProxyAiEngine implements AiEngine {
  final String apiKey;
  final String model;
  final http.Client _client;

  ProxyAiEngine({
    required this.apiKey,
    this.model = 'deep-seek-v4-pro',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> complete({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    // TODO: In production, route via a backend server to hide apiKey.
    // The key must NEVER be committed or shipped to clients.
    if (apiKey.isEmpty) {
      throw const AiException('AI assist unavailable (no key configured)');
    }

    final url = Uri.parse('https://www.genspark.ai/api/llm_proxy/v1/chat/completions');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode != 200) {
        throw AiException('Proxy returned status ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      
      if (content == null) {
        throw const AiException('Invalid response format: missing content');
      }

      return extractJsonFromLlmResponse(content);
    } catch (e) {
      if (e is AiException) rethrow;
      throw AiException('Network or parsing error', e);
    }
  }
}

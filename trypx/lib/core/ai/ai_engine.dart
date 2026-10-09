library;

abstract class AiEngine {
  Future<Map<String, dynamic>> complete({
    required String systemPrompt,
    required String userPrompt,
  });
}

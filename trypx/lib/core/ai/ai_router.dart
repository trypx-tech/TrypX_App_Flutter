library;

import 'dart:convert';
import 'ai_engine.dart';
import 'ai_task.dart';

class AiRouter {
  final AiEngine engine;

  const AiRouter(this.engine);

  Future<TOut> run<TOut>(AiTask<TOut> task, Map<String, dynamic> input) async {
    final systemPrompt = '''
${task.promptTemplate}

You MUST return STRICT JSON matching the following schema. Do NOT include any free-text parsing or markdown wrappers, just the raw JSON object.
Schema:
${task.jsonSchema}
''';

    final userPrompt = jsonEncode(input);

    final rawJson = await engine.complete(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );

    return task.parseResponse(rawJson);
  }
}

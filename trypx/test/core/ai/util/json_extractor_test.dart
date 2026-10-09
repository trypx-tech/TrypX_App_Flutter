import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/ai/util/json_extractor.dart';
import 'package:trypx/core/ai/ai_exception.dart';

void main() {
  group('extractJsonFromLlmResponse', () {
    test('parses clean JSON', () {
      final json = extractJsonFromLlmResponse('{"hello": "world"}');
      expect(json, equals({'hello': 'world'}));
    });

    test('extracts from markdown block', () {
      final input = '''
Here is the JSON:
```json
{
  "key": "value"
}
```
Hope this helps.
''';
      final json = extractJsonFromLlmResponse(input);
      expect(json, equals({'key': 'value'}));
    });

    test('extracts from generic code block', () {
      final input = '''
```
{"generic": "code"}
```
''';
      final json = extractJsonFromLlmResponse(input);
      expect(json, equals({'generic': 'code'}));
    });

    test('extracts from raw braces among text', () {
      final input = 'Text text text {"braces": "only"} text text';
      final json = extractJsonFromLlmResponse(input);
      expect(json, equals({'braces': 'only'}));
    });

    test('throws AiException on invalid format', () {
      expect(
        () => extractJsonFromLlmResponse('No JSON here at all'),
        throwsA(isA<AiException>()),
      );
    });
  });
}

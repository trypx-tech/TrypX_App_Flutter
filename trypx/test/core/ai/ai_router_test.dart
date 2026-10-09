import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/ai/ai_router.dart';
import 'package:trypx/core/ai/ai_engine.dart';
import 'package:trypx/core/ai/ai_exception.dart';
import 'package:trypx/core/ai/tasks/applicant_authenticity_task.dart';

class FakeAiEngine implements AiEngine {
  final Map<String, dynamic>? toReturn;
  final Exception? toThrow;

  FakeAiEngine({this.toReturn, this.toThrow});

  @override
  Future<Map<String, dynamic>> complete({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (toThrow != null) throw toThrow!;
    if (toReturn != null) return toReturn!;
    return {};
  }
}

void main() {
  group('AiRouter', () {
    test('run calls engine and parses ApplicantAuthenticityTask', () async {
      final engine = FakeAiEngine(toReturn: {
        'recommendation': 'waitlist',
        'confidence': 0.8,
        'reasons': ['Seems okay but sparse']
      });
      final router = AiRouter(engine);

      final result = await router.run(
        const ApplicantAuthenticityTask(),
        {'persona': 'public_creator'}
      );

      expect(result.recommendation, 'waitlist');
      expect(result.confidence, 0.8);
      expect(result.reasons, ['Seems okay but sparse']);
    });

    test('AiRouter does not change application status (invariant 12)', () async {
      final engine = FakeAiEngine(toReturn: {
        'recommendation': 'approve',
        'confidence': 1.0,
        'reasons': ['Looks perfect']
      });
      final router = AiRouter(engine);

      final input = {'status': 'submitted'};
      final result = await router.run(const ApplicantAuthenticityTask(), input);
      
      expect(result.recommendation, 'approve');
      // The router and task only return data; they have no ability to mutate
      // the application status. Proof is that the output is purely advisory.
      expect(input['status'], 'submitted');
    });

    test('throws AiException when engine fails', () async {
      final engine = FakeAiEngine(toThrow: const AiException('Network error'));
      final router = AiRouter(engine);

      expect(
        () => router.run(const ApplicantAuthenticityTask(), {}),
        throwsA(isA<AiException>()),
      );
    });
  });
}

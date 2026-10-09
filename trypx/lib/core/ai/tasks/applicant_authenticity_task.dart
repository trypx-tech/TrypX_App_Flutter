library;

import '../ai_task.dart';
import '../models/ai_recommendation.dart';

class ApplicantAuthenticityTask implements AiTask<AiRecommendation> {
  const ApplicantAuthenticityTask();

  @override
  String get promptTemplate => '''
You are an expert trust and safety reviewer for a travel creator application.
Review the provided applicant summary (including their persona, places, languages, and social handle).
Evaluate authenticity and provide a recommendation. This is ADVISORY ONLY.
''';

  @override
  String get jsonSchema => '''
{
  "type": "object",
  "properties": {
    "recommendation": {
      "type": "string",
      "enum": ["approve", "waitlist", "reject", "request_more_info"]
    },
    "confidence": {
      "type": "number",
      "description": "Confidence score from 0.0 to 1.0"
    },
    "reasons": {
      "type": "array",
      "items": { "type": "string" }
    }
  },
  "required": ["recommendation", "confidence", "reasons"]
}
''';

  @override
  AiRecommendation parseResponse(Map<String, dynamic> json) {
    return AiRecommendation.fromJson(json);
  }
}

library;

class AiRecommendation {
  final String recommendation;
  final double confidence;
  final List<String> reasons;

  const AiRecommendation({
    required this.recommendation,
    required this.confidence,
    required this.reasons,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      recommendation: json['recommendation'] as String? ?? 'request_more_info',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      reasons: (json['reasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

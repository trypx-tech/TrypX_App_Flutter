library;

abstract class AiTask<TOut> {
  String get promptTemplate;
  String get jsonSchema;
  
  TOut parseResponse(Map<String, dynamic> json);
}

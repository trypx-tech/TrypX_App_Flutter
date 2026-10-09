library;

class AiException implements Exception {
  final String message;
  final dynamic cause;

  const AiException(this.message, [this.cause]);

  @override
  String toString() => 'AiException: $message${cause != null ? '\nCause: $cause' : ''}';
}

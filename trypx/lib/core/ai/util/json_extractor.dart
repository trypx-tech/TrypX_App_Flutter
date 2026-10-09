library;

import 'dart:convert';
import '../ai_exception.dart';

Map<String, dynamic> extractJsonFromLlmResponse(String response) {
  try {
    return jsonDecode(response) as Map<String, dynamic>;
  } catch (_) {
    // Look for ```json ... ``` blocks
    final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = regex.firstMatch(response);
    if (match != null) {
      final jsonStr = match.group(1);
      if (jsonStr != null) {
        try {
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        } catch (e) {
          throw AiException('Failed to parse JSON extracted from code block', e);
        }
      }
    }
    
    // Look for curly braces if no code block
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');
    if (start != -1 && end != -1 && start < end) {
      final jsonStr = response.substring(start, end + 1);
      try {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        throw AiException('Failed to parse JSON extracted via braces', e);
      }
    }
    
    throw const AiException('Could not find valid JSON in LLM response');
  }
}

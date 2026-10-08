/// Stable location id from country + place name. Ported from LocationIds.kt.
/// Keeps letters of every script (so "京都" never collapses to empty).
/// Backs the 50-per-location cap (invariant 17).
class LocationIds {
  LocationIds._();

  static final RegExp _separators = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  static String slug(String name) {
    final lowered = name.trim().toLowerCase();
    final dashed = lowered.replaceAll(_separators, '-');
    return _trimChar(dashed, '-');
  }

  static bool isValidName(String name) => slug(name).isNotEmpty;

  static String of(String countryCode, String name) =>
      '${countryCode.trim().toLowerCase()}-${slug(name)}';

  static String _trimChar(String s, String ch) {
    var start = 0;
    var end = s.length;
    while (start < end && s[start] == ch) start++;
    while (end > start && s[end - 1] == ch) end--;
    return s.substring(start, end);
  }
}

const String kUnassignedReviewerId = 'unassigned';

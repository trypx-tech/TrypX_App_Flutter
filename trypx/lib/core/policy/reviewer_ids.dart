/// Reviewer ids look like "reviewer:sneha". Machines ("ai:","system:") and
/// "unassigned" are never human. Ported from ReviewerIds.kt.
library;

import 'location_ids.dart';

class ReviewerIds {
  ReviewerIds._();
  static const String prefix = 'reviewer:';
  static const List<String> _nonHumanPrefixes = ['ai:', 'system:'];

  static String? fromName(String name) {
    final s = LocationIds.slug(name);
    return s.isEmpty ? null : '$prefix$s';
  }

  static bool isHuman(String? reviewerId) {
    final id = (reviewerId ?? '').trim();
    if (id.isEmpty) return false;
    if (id.toLowerCase() == kUnassignedReviewerId) return false;
    final lower = id.toLowerCase();
    return !_nonHumanPrefixes.any(lower.startsWith);
  }
}

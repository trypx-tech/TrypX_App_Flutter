/// Decision validation. Ported from DecisionPolicy.kt.
/// A reason must be >= 10 chars. APPROVED/REJECTED are final.
library;

import '../models/enums.dart';
import 'reviewer_ids.dart';

const int kMinDecisionReasonLength = 10;

const List<ApplicationStatus> kReviewableStatuses = [
  ApplicationStatus.submitted,
  ApplicationStatus.inReview,
  ApplicationStatus.interviewScheduled,
  ApplicationStatus.waitlisted,
];

enum DecisionRejection {
  applicantNotFound,
  notReviewable,
  nonHumanReviewer,
  reasonTooShort,
}

class DecisionRequest {
  const DecisionRequest({
    required this.applicantId,
    required this.reviewerId,
    required this.outcome,
    required this.reason,
    this.aiRecommendation,
  });
  final String applicantId;
  final String reviewerId;
  final DecisionOutcome outcome;
  final String reason;

  /// Advisory only. Stored for audit, never applied (invariant 12).
  final DecisionOutcome? aiRecommendation;
}

class DecisionPolicy {
  DecisionPolicy._();

  static DecisionRejection? check(
      DecisionRequest request, ApplicationStatus? currentStatus) {
    if (currentStatus == null) return DecisionRejection.applicantNotFound;
    if (!kReviewableStatuses.contains(currentStatus)) {
      return DecisionRejection.notReviewable;
    }
    if (!ReviewerIds.isHuman(request.reviewerId)) {
      return DecisionRejection.nonHumanReviewer;
    }
    if (request.reason.trim().length < kMinDecisionReasonLength) {
      return DecisionRejection.reasonTooShort;
    }
    return null;
  }

  /// APPROVE returns null: only ApprovalGate may approve (language + cap).
  static ApplicationStatus? statusFor(DecisionOutcome outcome) {
    switch (outcome) {
      case DecisionOutcome.approve:
        return null;
      case DecisionOutcome.waitlist:
        return ApplicationStatus.waitlisted;
      case DecisionOutcome.reject:
        return ApplicationStatus.rejected;
      case DecisionOutcome.requestMoreInfo:
        return ApplicationStatus.inReview;
    }
  }
}

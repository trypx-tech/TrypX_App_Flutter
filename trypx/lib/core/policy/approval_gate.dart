/// Pure approval rules. Ported from ApprovalGate.kt. Order matters:
/// human decision -> human reviewer -> outcome -> language -> location cap.
/// Invariant 12: no approval without a human decision.
import '../models/enums.dart';

enum BlockReason {
  applicantNotFound,
  noHumanDecision,
  nonHumanReviewer,
  decisionNotApprove,
  missingLanguage,
  locationFull,
}

sealed class ApprovalResult {
  const ApprovalResult();
}

class Approved extends ApprovalResult {
  const Approved();
}

class Blocked extends ApprovalResult {
  const Blocked(this.reason);
  final BlockReason reason;
}

class ApprovalInput {
  const ApprovalInput({
    required this.latestDecision,
    required this.reviewerId,
    required this.languageCount,
    required this.approvedInLocation,
    required this.locationCap,
  });
  final DecisionOutcome? latestDecision;
  final String? reviewerId;
  final int languageCount;
  final int approvedInLocation;
  final int locationCap;
}

class ApprovalGate {
  ApprovalGate._();
  static const List<String> _nonHumanPrefixes = ['ai:', 'system:'];

  static ApprovalResult evaluate(ApprovalInput input) {
    final reviewer = (input.reviewerId ?? '').trim();
    final lower = reviewer.toLowerCase();
    BlockReason? reason;
    if (input.latestDecision == null || reviewer.isEmpty) {
      reason = BlockReason.noHumanDecision;
    } else if (_nonHumanPrefixes.any(lower.startsWith)) {
      reason = BlockReason.nonHumanReviewer;
    } else if (input.latestDecision != DecisionOutcome.approve) {
      reason = BlockReason.decisionNotApprove;
    } else if (input.languageCount < 1) {
      reason = BlockReason.missingLanguage;
    } else if (input.approvedInLocation >= input.locationCap) {
      reason = BlockReason.locationFull;
    }
    return reason == null ? const Approved() : Blocked(reason);
  }
}

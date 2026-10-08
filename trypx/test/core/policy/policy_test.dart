import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/models/enums.dart';
import 'package:trypx/core/policy/location_ids.dart';
import 'package:trypx/core/policy/reviewer_ids.dart';
import 'package:trypx/core/policy/approval_gate.dart';
import 'package:trypx/core/policy/decision_policy.dart';

void main() {
  group('LocationIds', () {
    test('case and spacing do not change the id', () {
      expect(LocationIds.of('JP', 'Kyoto'), LocationIds.of(' jp ', '  kyoto '));
    });
    test('punctuation collapses to a single dash', () {
      expect(LocationIds.of('JP', 'Gion, Kyoto'), 'jp-gion-kyoto');
    });
    test('non-Latin names are kept', () {
      expect(LocationIds.of('JP', '京都'), 'jp-京都');
    });
    test('punctuation-only name is invalid', () {
      expect(LocationIds.isValidName(' -- '), isFalse);
      expect(LocationIds.isValidName('Kyoto'), isTrue);
    });
  });

  group('ReviewerIds', () {
    test('machines and unassigned are not human', () {
      expect(ReviewerIds.isHuman('reviewer:sneha'), isTrue);
      expect(ReviewerIds.isHuman('ai:bot'), isFalse);
      expect(ReviewerIds.isHuman('system:x'), isFalse);
      expect(ReviewerIds.isHuman('unassigned'), isFalse);
      expect(ReviewerIds.isHuman(''), isFalse);
      expect(ReviewerIds.isHuman(null), isFalse);
    });
  });

  group('ApprovalGate (invariant 12 + 17)', () {
    ApprovalInput base({
      DecisionOutcome? d = DecisionOutcome.approve,
      String? r = 'reviewer:sneha',
      int lang = 1,
      int approved = 0,
      int cap = 50,
    }) =>
        ApprovalInput(
          latestDecision: d,
          reviewerId: r,
          languageCount: lang,
          approvedInLocation: approved,
          locationCap: cap,
        );

    test('approves a clean human APPROVE', () {
      expect(ApprovalGate.evaluate(base()), isA<Approved>());
    });
    test('blocks when no human decision', () {
      final res = ApprovalGate.evaluate(base(d: null));
      expect((res as Blocked).reason, BlockReason.noHumanDecision);
    });
    test('blocks a non-human reviewer', () {
      final res = ApprovalGate.evaluate(base(r: 'ai:bot'));
      expect((res as Blocked).reason, BlockReason.nonHumanReviewer);
    });
    test('blocks when no language', () {
      final res = ApprovalGate.evaluate(base(lang: 0));
      expect((res as Blocked).reason, BlockReason.missingLanguage);
    });
    test('blocks when location is full (cap 50)', () {
      final res = ApprovalGate.evaluate(base(approved: 50, cap: 50));
      expect((res as Blocked).reason, BlockReason.locationFull);
    });
  });

  group('DecisionPolicy', () {
    test('reason under 10 chars is rejected', () {
      final req = DecisionRequest(
        applicantId: 'a',
        reviewerId: 'reviewer:sneha',
        outcome: DecisionOutcome.reject,
        reason: 'too short',
      );
      expect(DecisionPolicy.check(req, ApplicationStatus.submitted),
          DecisionRejection.reasonTooShort);
    });
  });
}

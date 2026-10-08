/// F-07: Reviewer Console State
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/submission.dart';
import '../../../core/policy/decision_policy.dart';
import '../../../core/policy/approval_gate.dart';
import '../../../core/policy/location_ids.dart';

class ReviewableApplication {
  const ReviewableApplication({
    required this.id,
    required this.submission,
    required this.status,
    required this.submittedAtEpochMs,
  });
  final String id;
  final ApplicationSubmission submission;
  final ApplicationStatus status;
  final int submittedAtEpochMs;
}

class ReviewerState {
  const ReviewerState({
    required this.queue,
    required this.approvedInLocation,
    required this.decisions,
  });

  final List<ReviewableApplication> queue;
  final Map<String, int> approvedInLocation;
  final Map<String, DecisionRequest> decisions;

  ReviewerState copyWith({
    List<ReviewableApplication>? queue,
    Map<String, int>? approvedInLocation,
    Map<String, DecisionRequest>? decisions,
  }) {
    return ReviewerState(
      queue: queue ?? this.queue,
      approvedInLocation: approvedInLocation ?? this.approvedInLocation,
      decisions: decisions ?? this.decisions,
    );
  }
}

class ReviewerController extends StateNotifier<ReviewerState> {
  ReviewerController()
      : super(
          ReviewerState(
            queue: _sampleQueue,
            approvedInLocation: {'fr-paris': 49, 'jp-tokyo': 10},
            decisions: const {},
          ),
        );

  static final _sampleQueue = <ReviewableApplication>[
    ReviewableApplication(
      id: 'app-001',
      submission: ApplicationSubmission(
        persona: Persona.publicCreator,
        displayName: 'Alice Explorer',
        social: const SocialLink(platform: SocialPlatform.instagram, handle: '@alice'),
        places: const [
          PlaceClaim(name: 'Paris', countryCode: 'FR', depth: PlaceDepth.livedThere),
        ],
        languages: const [
          LanguageClaim(languageCode: 'en', level: ProficiencyLevel.native),
          LanguageClaim(languageCode: 'fr', level: ProficiencyLevel.fluent),
        ],
        interviewStartsAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
      status: ApplicationStatus.inReview,
      submittedAtEpochMs: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
    ),
    ReviewableApplication(
      id: 'app-002',
      submission: ApplicationSubmission(
        persona: Persona.silentExpert,
        displayName: 'Bob The Guide',
        social: null,
        places: const [
          PlaceClaim(name: 'Tokyo', countryCode: 'JP', depth: PlaceDepth.frequent),
        ],
        languages: const [
          LanguageClaim(languageCode: 'ja', level: ProficiencyLevel.native),
        ],
        interviewStartsAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
      status: ApplicationStatus.submitted,
      submittedAtEpochMs: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    ),
  ]..sort((a, b) => a.submittedAtEpochMs.compareTo(b.submittedAtEpochMs)); // Oldest first

  /// Process a decision request and return an evaluation result.
  ({DecisionRejection? rejection, ApprovalResult? approvalResult}) processDecision(
      DecisionRequest request) {
    final app = state.queue.firstWhere((a) => a.id == request.applicantId);
    
    final rejection = DecisionPolicy.check(request, app.status);
    if (rejection != null) {
      return (rejection: rejection, approvalResult: null);
    }

    // Record the decision (invariant 12 - do not automatically mutate status)
    state = state.copyWith(
      decisions: {
        ...state.decisions,
        request.applicantId: request,
      },
    );

    ApprovalResult? approvalResult;
    if (request.outcome == DecisionOutcome.approve) {
      // Get the primary location (using the first place for simplicity here)
      final primaryPlace = app.submission.places.first;
      final locId = LocationIds.of(primaryPlace.countryCode, primaryPlace.name);
      final currentApproved = state.approvedInLocation[locId] ?? 0;

      final input = ApprovalInput(
        latestDecision: request.outcome,
        reviewerId: request.reviewerId,
        languageCount: app.submission.languages.length,
        approvedInLocation: currentApproved,
        locationCap: kLocationSupplierCap,
      );
      approvalResult = ApprovalGate.evaluate(input);
    }

    return (rejection: null, approvalResult: approvalResult);
  }
}

final reviewerControllerProvider =
    StateNotifierProvider<ReviewerController, ReviewerState>((ref) {
  return ReviewerController();
});

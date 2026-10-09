library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../core/policy/decision_policy.dart';
import '../../../core/design_system/trypx_colors.dart';
import '../../../core/design_system/widgets/trypx_card.dart';
import '../../../core/design_system/widgets/trypx_primary_button.dart';
import '../../../core/design_system/widgets/trypx_text_field.dart';
import '../../../data/providers.dart';
import '../../../data/reviewer_repository.dart';
import '../../../core/ai/tasks/applicant_authenticity_task.dart';

class ReviewerQueueScreen extends ConsumerWidget {
  const ReviewerQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(reviewerQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviewer Queue'),
      ),
      body: queueAsync.when(
        data: (queue) {
          if (queue.isEmpty) {
            return const Center(child: Text('Queue is empty.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final app = queue[index];
              return TrypXCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicantDetailScreen(
                        applicantUid: app['uid'] as String,
                        applicantData: app,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app['displayName'] as String? ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Status: ${app['status']}'),
                      Text('Location: ${app['locationId']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  const ApplicantDetailScreen({
    super.key, 
    required this.applicantUid, 
    required this.applicantData,
  });
  
  final String applicantUid;
  final Map<String, dynamic> applicantData;

  @override
  ConsumerState<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  DecisionOutcome? _outcome;
  String _reason = '';
  String? _evaluationResult;
  bool _isSubmitting = false;

  bool _isAiLoading = false;
  String? _aiRecommendationText;

  @override
  Widget build(BuildContext context) {
    final canSubmit = _outcome != null && _reason.length >= kMinDecisionReasonLength && !_isSubmitting;
    
    final displayName = widget.applicantData['displayName'] as String? ?? 'Unknown';
    final persona = widget.applicantData['persona'] as String? ?? 'Unknown';
    final locationId = widget.applicantData['locationId'] as String? ?? 'Unknown';
    final languageCodes = List<String>.from(widget.applicantData['languageCodes'] ?? []);

    return Scaffold(
      appBar: AppBar(title: Text(displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Persona: $persona', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Location ID: $locationId', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Languages:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...languageCodes.map((l) => Text('- $l')),
          const Divider(height: 32),
          
          const Text('AI Assist (Advisory — a human decision is still required)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          if (_aiRecommendationText != null) ...[
            Text(_aiRecommendationText!, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
          ],
          TrypXPrimaryButton(
            text: _isAiLoading ? 'Loading AI...' : 'Get AI recommendation',
            enabled: !_isAiLoading,
            onPressed: () async {
              setState(() {
                _isAiLoading = true;
                _aiRecommendationText = null;
              });

              try {
                final router = ref.read(aiRouterProvider);
                final task = const ApplicantAuthenticityTask();
                
                final input = {
                  'persona': persona,
                  'places': [locationId],
                  'languages': languageCodes,
                  'socialHandle': widget.applicantData['socialHandle'] ?? 'None',
                };

                final rec = await router.run(task, input);

                if (mounted) {
                  setState(() {
                    _aiRecommendationText = 'Recommendation: ${rec.recommendation}\nConfidence: ${rec.confidence}\nReasons: ${rec.reasons.join(", ")}';
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _aiRecommendationText = 'Error: $e';
                  });
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isAiLoading = false;
                  });
                }
              }
            },
          ),
          
          const Divider(height: 32),
          const Text('Decision', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [DecisionOutcome.approve, DecisionOutcome.reject].map((o) {
              return ChoiceChip(
                label: Text(o.name),
                selected: _outcome == o,
                onSelected: (selected) {
                  if (selected) setState(() => _outcome = o);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TrypXTextField(
            label: 'Reason',
            value: _reason,
            onChanged: (val) => setState(() => _reason = val),
            singleLine: false,
          ),
          const SizedBox(height: 16),
          TrypXPrimaryButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Decision',
            enabled: canSubmit,
            onPressed: () async {
              setState(() {
                _isSubmitting = true;
                _evaluationResult = null;
              });

              final repo = ref.read(reviewerRepositoryProvider);
              final user = ref.read(authStateProvider).value;
              
              if (user == null) {
                setState(() {
                  _isSubmitting = false;
                  _evaluationResult = 'Error: Not signed in';
                });
                return;
              }

              final result = await repo.decide(
                applicantUid: widget.applicantUid,
                reviewerUid: user.uid,
                outcome: _outcome!,
                reason: _reason,
              );

              if (mounted) {
                setState(() {
                  _isSubmitting = false;
                  switch (result) {
                    case DecisionResult.success:
                      _evaluationResult = 'Success: Applicant ${_outcome!.name}';
                      break;
                    case DecisionResult.locationFull:
                      _evaluationResult = 'Blocked: Location Cap Reached (50)';
                      break;
                    case DecisionResult.notSubmitted:
                      _evaluationResult = 'Error: Application not in submitted state';
                      break;
                    case DecisionResult.permissionDenied:
                      _evaluationResult = 'Error: Permission denied by rules';
                      break;
                    case DecisionResult.error:
                      _evaluationResult = 'Error: Transaction failed';
                      break;
                  }
                });
              }
            },
          ),
          if (_evaluationResult != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _evaluationResult!,
                style: const TextStyle(
                  color: TrypXColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

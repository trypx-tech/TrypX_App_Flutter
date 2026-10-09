library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/enums.dart';
import '../../../core/policy/decision_policy.dart';
import '../../../core/design_system/trypx_colors.dart';
import '../../../core/design_system/trypx_spacing.dart';
import '../../../core/design_system/widgets/trypx_card.dart';
import '../../../core/design_system/widgets/trypx_primary_button.dart';
import '../../../core/design_system/widgets/trypx_text_field.dart';
import '../../../core/design_system/widgets/trypx_components.dart';
import '../../../data/providers.dart';
import '../../../data/reviewer_repository.dart';
import '../../../core/ai/tasks/applicant_authenticity_task.dart';

class ReviewerQueueScreen extends ConsumerWidget {
  const ReviewerQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(reviewerQueueProvider);

    return Scaffold(
      backgroundColor: TrypXColors.surfaceNavy,
      appBar: AppBar(
        backgroundColor: TrypXColors.surfaceNavy,
        elevation: 0,
        title: const Text('Reviewer Queue', style: TextStyle(color: TrypXColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: TrypXColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationSaturationScreen()),
              );
            },
            tooltip: 'Saturation',
          ),
        ],
      ),
      body: queueAsync.when(
        data: (queue) {
          if (queue.isEmpty) {
            return const TrypXEmptyState(
              title: 'Queue is clear',
              subtitle: 'There are no pending applications to review right now.',
              icon: Icons.done_all,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final app = queue[index];
              final submittedAt = app['submittedAt'] as Timestamp?;
              final timeAgo = submittedAt != null
                  ? '${DateTime.now().difference(submittedAt.toDate()).inHours}h ago'
                  : 'Just now';

              return Padding(
                padding: const EdgeInsets.only(bottom: TrypXSpacing.m),
                child: TrypXCard(
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app['displayName'] as String? ?? 'Unknown Applicant',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary),
                            ),
                            const SizedBox(height: TrypXSpacing.s),
                            Text(
                              'Location: ${app['locationId']}',
                              style: const TextStyle(color: TrypXColors.textSecondary),
                            ),
                            const SizedBox(height: TrypXSpacing.xs),
                            Text(
                              'Submitted: $timeAgo',
                              style: const TextStyle(color: TrypXColors.textTertiary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      TrypXStatusBadge(
                        text: (app['persona'] as String? ?? 'UNKNOWN').toUpperCase(),
                        color: TrypXColors.secondaryCyan,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: TrypXColors.primaryOrange)),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: TrypXColors.errorRed))),
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
      backgroundColor: TrypXColors.surfaceNavy,
      appBar: AppBar(
        backgroundColor: TrypXColors.surfaceNavy,
        elevation: 0,
        title: Text(displayName, style: const TextStyle(color: TrypXColors.textPrimary)),
        iconTheme: const IconThemeData(color: TrypXColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
          children: [
            // Summary Section
            const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
            const SizedBox(height: TrypXSpacing.m),
            TrypXCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Persona', persona),
                  const Divider(color: TrypXColors.borderDefault, height: TrypXSpacing.xxl),
                  _buildDetailRow('Location ID', locationId),
                ],
              ),
            ),
            const SizedBox(height: TrypXSpacing.xl),

            // Languages Section
            const Text('Languages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
            const SizedBox(height: TrypXSpacing.m),
            Wrap(
              spacing: TrypXSpacing.s,
              runSpacing: TrypXSpacing.s,
              children: languageCodes.map((l) => Chip(
                label: Text(l.toUpperCase()),
                backgroundColor: TrypXColors.cardNavy,
                labelStyle: const TextStyle(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold),
                side: const BorderSide(color: TrypXColors.borderDefault),
              )).toList(),
            ),
            const SizedBox(height: TrypXSpacing.xxl),
            
            // AI Assist Section
            const Text('AI Assist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
            const SizedBox(height: TrypXSpacing.xs),
            const Text('Advisory — a human decision is still required', style: TextStyle(fontSize: 12, color: TrypXColors.textTertiary)),
            const SizedBox(height: TrypXSpacing.m),
            TrypXCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_aiRecommendationText != null) ...[
                    Text(_aiRecommendationText!, style: const TextStyle(fontSize: 14, color: TrypXColors.textPrimary)),
                    const SizedBox(height: TrypXSpacing.m),
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
                            _aiRecommendationText = 'Recommendation: ${rec.recommendation.toUpperCase()}\nConfidence: ${(rec.confidence * 100).toInt()}%\nReasons:\n• ${rec.reasons.join("\n• ")}';
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
                ],
              ),
            ),
            const SizedBox(height: TrypXSpacing.xxl),
            
            // Decision Section
            const Text('Decision', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
            const SizedBox(height: TrypXSpacing.m),
            Wrap(
              spacing: TrypXSpacing.s,
              children: [DecisionOutcome.approve, DecisionOutcome.reject].map((o) {
                final isSelected = _outcome == o;
                return ChoiceChip(
                  label: Text(o.name.toUpperCase()),
                  selected: isSelected,
                  selectedColor: o == DecisionOutcome.approve ? TrypXColors.successGreen.withOpacity(0.2) : TrypXColors.errorRed.withOpacity(0.2),
                  backgroundColor: TrypXColors.cardNavy,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (o == DecisionOutcome.approve ? TrypXColors.successGreen : TrypXColors.errorRed)
                        : TrypXColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? (o == DecisionOutcome.approve ? TrypXColors.successGreen : TrypXColors.errorRed)
                        : TrypXColors.borderDefault,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _outcome = o);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: TrypXSpacing.base),
            TrypXTextField(
              label: 'Reason (Min 10 chars)',
              value: _reason,
              onChanged: (val) => setState(() => _reason = val),
              singleLine: false,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: TrypXSpacing.l),
              child: Text(
                '${_reason.length} / $kMinDecisionReasonLength min characters',
                style: TextStyle(
                  fontSize: 12,
                  color: _reason.length >= kMinDecisionReasonLength ? TrypXColors.successGreen : TrypXColors.textTertiary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            
            if (_evaluationResult != null)
              Padding(
                padding: const EdgeInsets.only(bottom: TrypXSpacing.l),
                child: Container(
                  padding: const EdgeInsets.all(TrypXSpacing.base),
                  decoration: BoxDecoration(
                    color: TrypXColors.navyContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _evaluationResult!.startsWith('Success') ? TrypXColors.successGreen : TrypXColors.warningOrange),
                  ),
                  child: Text(
                    _evaluationResult!,
                    style: TextStyle(
                      color: _evaluationResult!.startsWith('Success') ? TrypXColors.successGreen : TrypXColors.warningOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

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
            const SizedBox(height: TrypXSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: TrypXColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: TrypXColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class LocationSaturationScreen extends StatelessWidget {
  const LocationSaturationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy UI as per requirement "R-04 saturation"
    // Since we don't have a stream for this right now, just mock one or use static for UI polish.
    // In a real app we would read this from Firestore /locations collection.
    final mockLocations = [
      {'id': 'paris-fr', 'count': 50},
      {'id': 'tokyo-jp', 'count': 45},
      {'id': 'new-york-us', 'count': 12},
    ];

    return Scaffold(
      backgroundColor: TrypXColors.surfaceNavy,
      appBar: AppBar(
        backgroundColor: TrypXColors.surfaceNavy,
        elevation: 0,
        title: const Text('Location Saturation', style: TextStyle(color: TrypXColors.textPrimary)),
        iconTheme: const IconThemeData(color: TrypXColors.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
        itemCount: mockLocations.length,
        itemBuilder: (context, index) {
          final loc = mockLocations[index];
          final id = loc['id'] as String;
          final count = loc['count'] as int;
          final cap = 50;
          final double progress = count / cap;

          Color barColor = TrypXColors.secondaryCyan;
          if (count >= 50) {
            barColor = TrypXColors.errorRed;
          } else if (count >= 45) {
            barColor = TrypXColors.warningOrange;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: TrypXSpacing.m),
            child: TrypXCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(id, style: const TextStyle(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$count / $cap', style: TextStyle(color: barColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: TrypXSpacing.m),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: TrypXColors.navyContainerHigh,
                    color: barColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

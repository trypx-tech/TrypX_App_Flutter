/// F-07: Reviewer Console Screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../core/policy/approval_gate.dart';
import '../../../core/policy/decision_policy.dart';
import '../../../core/design_system/trypx_colors.dart';
import '../../../core/design_system/widgets/trypx_card.dart';
import '../../../core/design_system/widgets/trypx_primary_button.dart';
import '../../../core/design_system/widgets/trypx_text_field.dart';
import '../state/reviewer_controller.dart';

class ReviewerQueueScreen extends ConsumerWidget {
  const ReviewerQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviewer Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationSaturationScreen()),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.queue.length,
        itemBuilder: (context, index) {
          final app = state.queue[index];
          final decision = state.decisions[app.id];
          return TrypXCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplicantDetailScreen(applicantId: app.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.submission.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Status: ${app.status.name}'),
                  if (decision != null) Text('Decision Recorded: ${decision.outcome.name}', style: const TextStyle(color: TrypXColors.successGreen)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  const ApplicantDetailScreen({super.key, required this.applicantId, this.reviewerId = 'reviewer:admin'});
  final String applicantId;
  final String reviewerId;

  @override
  ConsumerState<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  DecisionOutcome? _outcome;
  String _reason = '';
  String? _evaluationResult;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewerControllerProvider);
    final app = state.queue.firstWhere((a) => a.id == widget.applicantId);
    final controller = ref.read(reviewerControllerProvider.notifier);

    final canSubmit = _outcome != null && _reason.length >= kMinDecisionReasonLength;

    return Scaffold(
      appBar: AppBar(title: Text(app.submission.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Persona: ${app.submission.persona.name}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Places:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...app.submission.places.map((p) => Text('- ${p.name} (${p.countryCode}) - ${p.depth.name}')),
          const SizedBox(height: 8),
          const Text('Languages:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...app.submission.languages.map((l) => Text('- ${l.languageCode} (${l.level.name})')),
          const Divider(height: 32),
          const Text('Decision', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: DecisionOutcome.values.map((o) {
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
            text: 'Submit Decision',
            enabled: canSubmit,
            onPressed: () {
              final request = DecisionRequest(
                applicantId: app.id,
                reviewerId: widget.reviewerId,
                outcome: _outcome!,
                reason: _reason,
              );
              final result = controller.processDecision(request);
              setState(() {
                if (result.rejection != null) {
                  _evaluationResult = 'Rejected by Policy: ${result.rejection!.name}';
                } else if (result.approvalResult != null) {
                  if (result.approvalResult is Approved) {
                    _evaluationResult = 'Approved';
                  } else if (result.approvalResult is Blocked) {
                    final block = result.approvalResult as Blocked;
                    _evaluationResult = 'Blocked: ${block.reason.name}';
                  }
                } else {
                  _evaluationResult = 'Decision recorded (No approval evaluated)';
                }
              });
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

class LocationSaturationScreen extends ConsumerWidget {
  const LocationSaturationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Location Saturation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: state.approvedInLocation.entries.map((e) {
          return TrypXCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${e.value} / $kLocationSupplierCap', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

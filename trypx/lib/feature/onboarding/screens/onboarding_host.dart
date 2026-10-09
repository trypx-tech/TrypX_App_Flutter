library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/submission.dart';
import '../../../core/models/enums.dart';
import '../../../core/onboarding/onboarding_step.dart';
import '../../../core/onboarding/onboarding_flow.dart';
import '../../../core/design_system/trypx_colors.dart';
import '../../../core/design_system/trypx_spacing.dart';
import '../../../core/design_system/widgets/trypx_primary_button.dart';
import '../../../core/design_system/widgets/trypx_card.dart';
import '../../../core/design_system/widgets/trypx_text_field.dart';
import '../../../core/design_system/widgets/trypx_components.dart';
import '../state/onboarding_controller.dart';

class OnboardingHost extends ConsumerWidget {
  const OnboardingHost({super.key, required this.onSubmit});

  final void Function(ApplicationSubmission) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final stepIndex = draft.flowState.step.index;
    final totalSteps = OnboardingStep.values.length;

    Widget screen;
    switch (draft.flowState.step) {
      case OnboardingStep.roleSelect:
        screen = const RoleSelectScreen();
        break;
      case OnboardingStep.applicantLanding:
        screen = const ApplicantLandingScreen();
        break;
      case OnboardingStep.connectStory:
        screen = const ConnectStoryScreen();
        break;
      case OnboardingStep.connectSocial:
        screen = const ConnectSocialScreen();
        break;
      case OnboardingStep.manualPlaces:
        screen = const ManualPlacesScreen();
        break;
      case OnboardingStep.placesYouKnow:
        screen = const PlacesYouKnowScreen();
        break;
      case OnboardingStep.languages:
        screen = const LanguagesScreen();
        break;
      case OnboardingStep.interviewSlot:
        screen = const InterviewSlotScreen();
        break;
      case OnboardingStep.whatHappensNext:
        screen = const WhatHappensNextScreen();
        break;
    }

    final isFirstStep = draft.flowState.step == OnboardingStep.roleSelect;

    return Scaffold(
      backgroundColor: TrypXColors.surfaceNavy,
      appBar: TrypXTopBar(
        currentStep: stepIndex + 1,
        totalSteps: totalSteps,
        onBack: isFirstStep ? null : controller.goBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (draft.validation is StepInvalid)
              Container(
                color: TrypXColors.errorRed,
                width: double.infinity,
                padding: const EdgeInsets.all(TrypXSpacing.s),
                child: Text(
                  'Error: ${(draft.validation as StepInvalid).reason.name}',
                  style: const TextStyle(color: TrypXColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(child: screen),
            if (draft.flowState.step != OnboardingStep.roleSelect) // roleSelect advances automatically
              Padding(
                padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
                child: draft.flowState.step == OnboardingStep.whatHappensNext
                    ? TrypXPrimaryButton(
                        text: 'Submit application',
                        fillsWidth: true,
                        onPressed: () {
                          final sub = controller.buildSubmission();
                          if (sub != null) {
                            onSubmit(sub);
                          }
                        },
                      )
                    : Column(
                        children: [
                          if (draft.flowState.step == OnboardingStep.languages && draft.flowState.languages.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: TrypXSpacing.s),
                              child: Text('Add at least one language to continue', style: TextStyle(color: TrypXColors.textSecondary)),
                            ),
                          TrypXPrimaryButton(
                            text: 'Next',
                            fillsWidth: true,
                            enabled: draft.validation is StepValid,
                            onPressed: () {
                              controller.advance();
                            },
                          ),
                        ],
                      ),
              )
          ],
        ),
      ),
    );
  }
}

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        Text('How will you use TrypX?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: TrypXSpacing.s),
        const Text('Choose the persona that fits you best.', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16)),
        const SizedBox(height: TrypXSpacing.xl),
        TrypXSelectionCard(
          title: 'Public Creator',
          description: 'Share your travel stories and connect publicly with followers.',
          icon: Icons.camera_alt,
          isSelected: draft.flowState.persona == Persona.publicCreator,
          onTap: () {
            controller.setRole(Persona.publicCreator);
            controller.advance();
          },
        ),
        const SizedBox(height: TrypXSpacing.base),
        TrypXSelectionCard(
          title: 'Silent Expert',
          description: 'Curate hidden gems and share knowledge anonymously.',
          icon: Icons.map,
          isSelected: draft.flowState.persona == Persona.silentExpert,
          onTap: () {
            controller.setRole(Persona.silentExpert);
            controller.advance();
          },
        ),
      ],
    );
  }
}

class ApplicantLandingScreen extends ConsumerWidget {
  const ApplicantLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    
    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        Text('Tell us about yourself', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: TrypXSpacing.s),
        const Text('What should we call you?', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16)),
        const SizedBox(height: TrypXSpacing.xl),
        TrypXTextField(
          label: 'Display Name',
          value: draft.displayName,
          onChanged: controller.setDisplayName,
        ),
      ],
    );
  }
}

class ConnectStoryScreen extends StatelessWidget {
  const ConnectStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: TrypXSpacing.xxl),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: TrypXColors.cardNavy,
              child: Icon(Icons.auto_stories, size: 48, color: TrypXColors.secondaryCyan),
            ),
          ),
        ),
        Text('Your Story Matters', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: TrypXSpacing.s),
        const Text('We want to know what makes you travel. Connect your story to help us understand your perspective.', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16), textAlign: TextAlign.center),
      ],
    );
  }
}

class ConnectSocialScreen extends ConsumerWidget {
  const ConnectSocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    
    final platforms = [
      {'name': 'Instagram', 'icon': Icons.camera_alt, 'value': SocialPlatform.instagram},
      {'name': 'TikTok', 'icon': Icons.music_note, 'value': SocialPlatform.tiktok},
      {'name': 'YouTube', 'icon': Icons.play_arrow, 'value': SocialPlatform.youtube},
      {'name': 'Facebook', 'icon': Icons.facebook, 'value': SocialPlatform.facebook},
    ];

    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        Text('Connect your social profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: TrypXSpacing.s),
        const Text('Link an account to instantly import your top locations.', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16)),
        const SizedBox(height: TrypXSpacing.xl),
        ...platforms.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: TrypXSpacing.base),
          child: TrypXCard(
            onTap: () {
              controller.setSocial(SocialLink(platform: p['value'] as SocialPlatform, handle: 'example'));
            },
            child: Row(
              children: [
                Icon(p['icon'] as IconData, color: TrypXColors.secondaryCyan),
                const SizedBox(width: TrypXSpacing.base),
                Text(p['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
              ],
            ),
          ),
        )),
        const SizedBox(height: TrypXSpacing.xl),
        Center(
          child: TrypXTextButton(
            text: "Skip — I'll add places manually",
            onPressed: () {
              controller.setSocial(null, skipped: true);
              controller.advance();
            },
          ),
        ),
      ],
    );
  }
}

class ManualPlacesScreen extends StatelessWidget {
  const ManualPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlacesYouKnowScreen(); // Reuse the same UI for manual
  }
}

class PlacesYouKnowScreen extends ConsumerWidget {
  const PlacesYouKnowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    
    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        Text('Places you know best', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: TrypXSpacing.s),
        const Text('Add locations where you have deep experience.', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16)),
        const SizedBox(height: TrypXSpacing.xl),
        ...draft.flowState.places.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: TrypXSpacing.s),
          child: TrypXCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
                TrypXStatusBadge(text: p.depth.name, color: TrypXColors.secondaryCyan),
              ],
            ),
          ),
        )),
        const SizedBox(height: TrypXSpacing.m),
        TrypXTextButton(
          text: '+ Add place',
          onPressed: () {
            controller.addPlace(const PlaceClaim(name: 'Paris', countryCode: 'FR', depth: PlaceDepth.livedThere));
          },
        ),
      ],
    );
  }
}

class LanguagesScreen extends ConsumerWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    
    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        Text('Languages', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: TrypXSpacing.s),
        const Text('What languages do you speak?', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16)),
        const SizedBox(height: TrypXSpacing.xl),
        Wrap(
          spacing: TrypXSpacing.s,
          runSpacing: TrypXSpacing.s,
          children: draft.flowState.languages.map((l) => Chip(
            label: Text(l.languageCode),
            backgroundColor: TrypXColors.cardNavy,
            labelStyle: const TextStyle(color: TrypXColors.textPrimary),
            deleteIconColor: TrypXColors.textSecondary,
            onDeleted: () {
              // Not implemented
            },
          )).toList(),
        ),
        const SizedBox(height: TrypXSpacing.xl),
        TrypXTextButton(
          text: '+ Add English',
          onPressed: () {
            controller.addLanguage(const LanguageClaim(languageCode: 'en', level: ProficiencyLevel.native));
          },
        ),
      ],
    );
  }
}

class InterviewSlotScreen extends ConsumerWidget {
  const InterviewSlotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    
    return ListView(
      padding: const EdgeInsets.all(TrypXSpacing.screenHorizontal),
      children: [
        Text('Schedule Interview', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: TrypXColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: TrypXSpacing.s),
        const Text('Select a time to chat with our team.', style: TextStyle(color: TrypXColors.textSecondary, fontSize: 16)),
        const SizedBox(height: TrypXSpacing.xl),
        TrypXCard(
          onTap: () {
            controller.setInterviewSlot(DateTime.now());
          },
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(TrypXSpacing.m),
              child: Text('Pick earliest available slot', style: TextStyle(fontSize: 16, color: TrypXColors.secondaryCyan, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}

class WhatHappensNextScreen extends StatelessWidget {
  const WhatHappensNextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrypXEmptyState(
      title: 'Ready to submit',
      subtitle: 'Your application is complete. After you submit, a human reviewer will assess your profile. We will notify you once a decision is made.',
      icon: Icons.check_circle_outline,
    );
  }
}

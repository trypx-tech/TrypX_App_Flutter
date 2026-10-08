import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/submission.dart';
import '../../../core/models/enums.dart';
import '../../../core/onboarding/onboarding_step.dart';
import '../../../core/onboarding/onboarding_flow.dart';
import '../../../core/design_system/trypx_colors.dart';
import '../../../core/design_system/widgets/trypx_primary_button.dart';
import '../../../core/design_system/widgets/trypx_card.dart';
import '../../../core/design_system/widgets/trypx_text_field.dart';
import '../state/onboarding_controller.dart';

class OnboardingHost extends ConsumerWidget {
  const OnboardingHost({super.key, required this.onSubmit});

  final void Function(ApplicationSubmission) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(draft.flowState.step.name),
        leading: draft.flowState.step == OnboardingStep.roleSelect
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.goBack,
              ),
      ),
      body: Column(
        children: [
          if (draft.validation is StepInvalid)
            Container(
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: Text(
                'Error: ${(draft.validation as StepInvalid).reason.name}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          Expanded(child: screen),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: draft.flowState.step == OnboardingStep.whatHappensNext
                ? TrypXPrimaryButton(
                    text: 'Submit',
                    fillsWidth: true,
                    onPressed: () {
                      final sub = controller.buildSubmission();
                      if (sub != null) {
                        onSubmit(sub);
                      }
                    },
                  )
                : TrypXPrimaryButton(
                    text: 'Next',
                    fillsWidth: true,
                    onPressed: () {
                      controller.advance();
                    },
                  ),
          )
        ],
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
      padding: const EdgeInsets.all(16),
      children: [
        TrypXCard(
          borderAccent: draft.flowState.persona == Persona.publicCreator ? TrypXColors.primaryOrange : null,
          onTap: () {
            controller.setRole(Persona.publicCreator);
            controller.advance();
          },
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Public Creator'),
          ),
        ),
        const SizedBox(height: 16),
        TrypXCard(
          borderAccent: draft.flowState.persona == Persona.silentExpert ? TrypXColors.primaryOrange : null,
          onTap: () {
            controller.setRole(Persona.silentExpert);
            controller.advance();
          },
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Silent Expert'),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TrypXTextField(
        label: 'Display Name',
        value: draft.displayName,
        onChanged: controller.setDisplayName,
      ),
    );
  }
}

class ConnectStoryScreen extends StatelessWidget {
  const ConnectStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Connect Story'));
  }
}

class ConnectSocialScreen extends ConsumerWidget {
  const ConnectSocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Connect your social profile'),
          TrypXPrimaryButton(
            text: 'Skip / add manually',
            onPressed: () {
              controller.setSocial(null, skipped: true);
              controller.advance();
            },
          ),
        ],
      ),
    );
  }
}

class ManualPlacesScreen extends StatelessWidget {
  const ManualPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Manual Places'));
  }
}

class PlacesYouKnowScreen extends ConsumerWidget {
  const PlacesYouKnowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...draft.flowState.places.map((p) => ListTile(title: Text(p.name))),
        TrypXPrimaryButton(
          text: 'Add Deep Place',
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
      padding: const EdgeInsets.all(16),
      children: [
        ...draft.flowState.languages.map((l) => ListTile(title: Text(l.languageCode))),
        TrypXPrimaryButton(
          text: 'Add English',
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
    return Center(
      child: TrypXPrimaryButton(
        text: 'Pick Slot',
        onPressed: () {
          controller.setInterviewSlot(DateTime.now());
        },
      ),
    );
  }
}

class WhatHappensNextScreen extends StatelessWidget {
  const WhatHappensNextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('What Happens Next'));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design_system/trypx_theme.dart';
import 'feature/onboarding/screens/onboarding_host.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrypX',
      theme: trypxDarkTheme(),
      home: OnboardingHost(
        onSubmit: (submission) {
          // Temporarily print submission and show a dialog
          debugPrint('Submission complete: ${submission.toJson()}');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Application Submitted'),
              content: const Text('Success! Next up is F-09 (Firestore).'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

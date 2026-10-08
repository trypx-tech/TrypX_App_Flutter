library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/design_system/trypx_theme.dart';
import 'core/design_system/widgets/trypx_primary_button.dart';
import 'feature/onboarding/screens/onboarding_host.dart';
import 'feature/reviewer/screens/reviewer_screens.dart';
import 'data/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: TrypXPrimaryButton(
                text: 'Sign in with Google',
                onPressed: () async {
                  await signInWithGoogle(ref);
                },
              ),
            );
          }
          return const HomeMenu();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class HomeMenu extends ConsumerWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrypX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(firebaseAuthProvider).signOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as: ${user?.email}'),
            const SizedBox(height: 32),
            TrypXPrimaryButton(
              text: 'Apply (Onboarding)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnboardingHost(
                      onSubmit: (submission) async {
                        final repo = ref.read(applicationRepositoryProvider);
                        await repo.submitApplication(submission, uid: user!.uid);
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Application Submitted'),
                              content: const Text('Your application was submitted successfully.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TrypXPrimaryButton(
              text: 'Reviewer Console',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReviewerQueueScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

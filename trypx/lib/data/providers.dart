library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'application_repository.dart';
import 'reviewer_repository.dart';
import '../core/ai/ai_router.dart';
import '../core/ai/engines/proxy_engine.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(firestore: FirebaseFirestore.instance);
});

final reviewerRepositoryProvider = Provider<ReviewerRepository>((ref) {
  return ReviewerRepository(firestore: FirebaseFirestore.instance);
});

final reviewerQueueProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(reviewerRepositoryProvider).watchQueue();
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final aiRouterProvider = Provider<AiRouter>((ref) {
  const apiKey = String.fromEnvironment('GSK_API_KEY');
  return AiRouter(ProxyAiEngine(apiKey: apiKey));
});

Future<UserCredential> signInWithGoogle(WidgetRef ref) async {
  final googleSignIn = ref.read(googleSignInProvider);
  final auth = ref.read(firebaseAuthProvider);

  // Initialize must be called exactly once before any other method.
  // We can try to initialize, and if it throws because it's already initialized, we ignore it.
  try {
    await googleSignIn.initialize();
  } catch (_) {
    // Ignore already initialized
  }

  // authenticate() throws GoogleSignInException on cancellation or failure.
  final googleUser = await googleSignIn.authenticate();
  
  final googleAuth = googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );

  return await auth.signInWithCredential(credential);
}

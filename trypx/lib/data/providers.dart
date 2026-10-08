library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'application_repository.dart';
import 'reviewer_repository.dart';

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

Future<UserCredential?> signInWithGoogle(WidgetRef ref) async {
  final googleSignIn = ref.read(googleSignInProvider);
  final auth = ref.read(firebaseAuthProvider);

  // Initialize if not already (assuming default configs are fine for this context)
  try {
    await googleSignIn.initialize();
  } catch (e) {
    // Already initialized or initialization failed, proceed
  }

  try {
    final googleUser = await googleSignIn.authenticate();
    
    // In version 7, authentication is a getter, not a future.
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      // accessToken is only available via the authorization API in v7,
      // but idToken is sufficient for Firebase Auth.
    );

    return await auth.signInWithCredential(credential);
  } catch (e) {
    return null;
  }
}

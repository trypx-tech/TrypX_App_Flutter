library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/submission.dart';
import '../core/policy/location_ids.dart';
import 'firestore_mappers.dart';

class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitApplication(
    ApplicationSubmission submission, {
    required String uid,
  }) async {
    final deepPlace = submission.places.firstWhere(
      (p) => p.depth.isDeep,
      orElse: () => submission.places.first,
    );
    
    final locationId = LocationIds.of(deepPlace.countryCode, deepPlace.name);
    final languageCodes =
        submission.languages.map((l) => l.languageCode).toList();

    final data = <String, dynamic>{
      'displayName': submission.displayName,
      'persona': personaToWire(submission.persona),
      'locationId': locationId,
      'languageCodes': languageCodes,
      'voiceSamplePath': 'voice_samples/$uid/submission',
      'status': 'submitted',
      'submittedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('applicants').doc(uid).set(data);
  }

  Stream<Map<String, dynamic>?> watchMyApplication(String uid) {
    return _firestore
        .collection('applicants')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data());
  }
}

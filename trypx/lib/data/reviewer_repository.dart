library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/enums.dart';
import 'firestore_mappers.dart';

enum DecisionResult {
  success,
  locationFull,
  notSubmitted,
  permissionDenied,
  error,
}

class ReviewerRepository {
  ReviewerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Map<String, dynamic>>> watchQueue() {
    return _firestore
        .collection('applicants')
        .where('status', isEqualTo: 'submitted')
        .orderBy('submittedAt')
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        data['uid'] = d.id;
        return data;
      }).toList();
    });
  }

  Future<DecisionResult> decide({
    required String applicantUid,
    required String reviewerUid,
    required DecisionOutcome outcome,
    required String reason,
  }) async {
    try {
      final applicantRef = _firestore.collection('applicants').doc(applicantUid);
      final decisionRef = _firestore.collection('reviewer_decisions').doc(applicantUid);

      final result = await _firestore.runTransaction<DecisionResult>((tx) async {
        // Read all documents first to satisfy Firestore transaction constraints.
        final applicantSnap = await tx.get(applicantRef);
        if (!applicantSnap.exists) {
          return DecisionResult.error;
        }

        final applicantData = applicantSnap.data()!;
        if (applicantData['status'] != 'submitted') {
          return DecisionResult.notSubmitted;
        }
        
        final decisionSnap = await tx.get(decisionRef);
        if (decisionSnap.exists) {
          return DecisionResult.notSubmitted;
        }

        final locationId = applicantData['locationId'] as String;
        final locationRef = _firestore.collection('locations').doc(locationId);
        final locationSnap = await tx.get(locationRef);

        final outcomeStr = outcomeToWire(outcome);
        
        if (outcomeStr == 'approved') {
          final currentCount = locationSnap.exists 
              ? (locationSnap.data()!['approvedCount'] as int? ?? 0) 
              : 0;
              
          if (currentCount >= kLocationSupplierCap) {
            return DecisionResult.locationFull;
          }
          
          tx.set(
            locationRef, 
            {
              'approvedCount': FieldValue.increment(1),
              'lastApprovedApplicantUid': applicantUid,
              if (!locationSnap.exists) 'active': true,
            }, 
            SetOptions(merge: true),
          );
        }

        tx.set(decisionRef, {
          'applicantUid': applicantUid,
          'locationId': locationId,
          'outcome': outcomeStr,
          'reason': reason.trim(),
          'reviewerUid': reviewerUid,
          'decidedAt': FieldValue.serverTimestamp(),
        });

        tx.update(applicantRef, {
          'status': outcomeStr,
        });

        return DecisionResult.success;
      });
      return result;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return DecisionResult.permissionDenied;
      }
      return DecisionResult.error;
    } catch (e) {
      return DecisionResult.error;
    }
  }
}

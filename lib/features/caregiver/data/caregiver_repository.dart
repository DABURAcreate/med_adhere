import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';

/// Manages caregiver linking — persists locally (SQLite) and pushes to
/// Firestore when online so workers can see who is linked.
class CaregiverRepository {
  final AppDatabase _db;

  CaregiverRepository({required AppDatabase db}) : _db = db;

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns the linked caregiver's phone and relationship, or null if none.
  Future<({String phone, String relationship})?> getCaregiver(
      int patientId) async {
    final patient = await _db.patientsDao.getPatientById(patientId);
    if (patient == null) return null;
    final phone = patient.caregiverPhone;
    if (phone == null || phone.isEmpty) return null;
    return (
      phone: phone,
      relationship: patient.caregiverRelationship ?? 'Other',
    );
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Links (or updates) the caregiver for [patientId].
  Future<void> linkCaregiver(
    int patientId, {
    required String phone,
    required String relationship,
  }) async {
    await _db.patientsDao.updateCaregiverInfo(
      patientId,
      phone: phone,
      relationship: relationship,
    );
    await _pushToFirestore(patientId, phone: phone, relationship: relationship);
  }

  /// Removes the caregiver link for [patientId].
  Future<void> unlinkCaregiver(int patientId) async {
    await _db.patientsDao.updateCaregiverInfo(
      patientId,
      phone: null,
      relationship: null,
    );
    await _pushToFirestore(patientId, phone: null, relationship: null);
  }

  // ── Firestore sync ─────────────────────────────────────────────────────────

  Future<void> _pushToFirestore(
    int patientId, {
    required String? phone,
    required String? relationship,
  }) async {
    if (!kFirebaseConfigured) return;
    try {
      final fs = FirebaseFirestore.instance;
      final snap = await fs
          .collection(kColPatients)
          .where('localId', isEqualTo: patientId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return;
      await snap.docs.first.reference.update({
        'caregiverPhone': phone,
        'caregiverRelationship': relationship,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[CaregiverRepo] Firestore push failed: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/call_model.dart';

class CallHistoryService {
  CallHistoryService._();

  static final CallHistoryService instance = CallHistoryService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  // ---------------------------------------------------------------------------
  // CREATE CALL
  // ---------------------------------------------------------------------------

  Future<void> createCall({
    required String callId,
    required String callerId,
    required String callerName,
    String? callerPhotoUrl,
    required String calleeId,
    required String calleeName,
    String? calleePhotoUrl,
    required CallType type,
  }) async {
    await _calls.doc(callId).set({
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,

      'calleeId': calleeId,
      'calleeName': calleeName,
      'calleePhotoUrl': calleePhotoUrl,

      // Used to fetch both incoming and outgoing calls.
      'participants': [callerId, calleeId],

      'type': type.name,
      'status': CallStatus.calling.name,

      'createdAt': FieldValue.serverTimestamp(),
      'connectedAt': null,
      'endedAt': null,
      'durationSeconds': 0,
    });
  }

  // ---------------------------------------------------------------------------
  // MARK CONNECTED
  // ---------------------------------------------------------------------------

  Future<void> markConnected(String callId) async {
    try {
      await _calls.doc(callId).update({
        'status': CallStatus.connected.name,
        'connectedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Call history should never break the actual ZEGOCLOUD call.
    }
  }

  // ---------------------------------------------------------------------------
  // MARK REJECTED
  // ---------------------------------------------------------------------------

  Future<void> markRejected(String callId) async {
    try {
      await _calls.doc(callId).update({
        'status': CallStatus.rejected.name,
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': 0,
      });
    } catch (_) {
      // Do not affect calling functionality.
    }
  }

  // ---------------------------------------------------------------------------
  // MARK MISSED
  // ---------------------------------------------------------------------------

  Future<void> markMissed(String callId) async {
    try {
      await _calls.doc(callId).update({
        'status': CallStatus.missed.name,
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': 0,
      });
    } catch (_) {
      // Do not affect calling functionality.
    }
  }

  // ---------------------------------------------------------------------------
  // MARK BUSY
  // ---------------------------------------------------------------------------

  Future<void> markBusy(String callId) async {
    try {
      await _calls.doc(callId).update({
        'status': CallStatus.busy.name,
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': 0,
      });
    } catch (_) {
      // Do not affect calling functionality.
    }
  }

  // ---------------------------------------------------------------------------
  // MARK ENDED
  // ---------------------------------------------------------------------------

  Future<void> markEnded(String callId, {int durationSeconds = 0}) async {
    try {
      final doc = await _calls.doc(callId).get();

      if (!doc.exists) return;

      final data = doc.data();

      final status = data?['status'] as String?;

      // Do not turn missed/rejected/busy calls into ended calls.
      if (status != CallStatus.connected.name) {
        return;
      }

      await _calls.doc(callId).update({
        'status': CallStatus.ended.name,
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': durationSeconds,
      });
    } catch (_) {
      // Call history should never break the actual call.
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Whether the call is audio-only or audio + video.
enum CallType { audio, video }

/// Lifecycle states of a call.
enum CallStatus {
  calling,
  ringing,
  connected,
  ended,
  rejected,
  missed,
  busy,
  failed,
  disconnected,
}

CallType callTypeFromString(String value) {
  return CallType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CallType.audio,
  );
}

CallStatus callStatusFromString(String value) {
  return CallStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CallStatus.ended,
  );
}

/// Represents an active or past call.
///
/// Stored in:
///
/// calls/{callId}
class CallModel {
  final String id;

  final String callerId;
  final String callerName;
  final String? callerPhotoUrl;

  final String calleeId;
  final String calleeName;
  final String? calleePhotoUrl;

  final CallType type;
  final CallStatus status;

  final DateTime createdAt;
  final DateTime? connectedAt;
  final DateTime? endedAt;

  /// Duration saved by Firestore when the call ends.
  final int durationSeconds;

  const CallModel({
    required this.id,

    required this.callerId,
    required this.callerName,
    this.callerPhotoUrl,

    required this.calleeId,
    required this.calleeName,
    this.calleePhotoUrl,

    required this.type,
    required this.status,

    required this.createdAt,
    this.connectedAt,
    this.endedAt,

    this.durationSeconds = 0,
  });

  // ---------------------------------------------------------------------------
  // CALL DURATION
  // ---------------------------------------------------------------------------

  Duration get duration {
    // Prefer the duration explicitly stored in Firestore.
    if (durationSeconds > 0) {
      return Duration(seconds: durationSeconds);
    }

    // If the call is currently connected, calculate live duration.
    if (connectedAt != null) {
      final end = endedAt ?? DateTime.now();

      final calculated = end.difference(connectedAt!);

      if (calculated.isNegative) {
        return Duration.zero;
      }

      return calculated;
    }

    return Duration.zero;
  }

  // ---------------------------------------------------------------------------
  // FROM FIRESTORE
  // ---------------------------------------------------------------------------

  factory CallModel.fromMap(String id, Map<String, dynamic> map) {
    return CallModel(
      id: id,

      callerId: map['callerId'] as String? ?? '',
      callerName: map['callerName'] as String? ?? '',
      callerPhotoUrl: map['callerPhotoUrl'] as String?,

      calleeId: map['calleeId'] as String? ?? '',
      calleeName: map['calleeName'] as String? ?? '',
      calleePhotoUrl: map['calleePhotoUrl'] as String?,

      type: callTypeFromString(map['type'] as String? ?? 'audio'),

      status: callStatusFromString(map['status'] as String? ?? 'ended'),

      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

      connectedAt: (map['connectedAt'] as Timestamp?)?.toDate(),

      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),

      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  // ---------------------------------------------------------------------------
  // TO FIRESTORE
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,

      'calleeId': calleeId,
      'calleeName': calleeName,
      'calleePhotoUrl': calleePhotoUrl,

      // Keep participants in the model too.
      'participants': [callerId, calleeId],

      'type': type.name,
      'status': status.name,

      'createdAt': Timestamp.fromDate(createdAt),

      'connectedAt': connectedAt != null
          ? Timestamp.fromDate(connectedAt!)
          : null,

      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,

      'durationSeconds': durationSeconds,
    };
  }
}

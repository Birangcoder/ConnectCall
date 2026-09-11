import 'package:cloud_firestore/cloud_firestore.dart';

/// Whether the call is audio-only or audio+video.
enum CallType { audio, video }

/// Lifecycle states a call moves through.
/// calling -> ringing -> connected -> ended
/// (or rejected / missed / busy / failed / disconnected at any point)
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

CallType callTypeFromString(String value) =>
    CallType.values.firstWhere((e) => e.name == value, orElse: () => CallType.audio);

CallStatus callStatusFromString(String value) => CallStatus.values
    .firstWhere((e) => e.name == value, orElse: () => CallStatus.ended);

/// Represents an active or past call, stored under `calls/{callId}`.
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
  });

  Duration get duration {
    if (connectedAt == null) return Duration.zero;
    final end = endedAt ?? DateTime.now();
    return end.difference(connectedAt!);
  }

  factory CallModel.fromMap(String id, Map<String, dynamic> map) {
    return CallModel(
      id: id,
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String? ?? '',
      callerPhotoUrl: map['callerPhotoUrl'] as String?,
      calleeId: map['calleeId'] as String,
      calleeName: map['calleeName'] as String? ?? '',
      calleePhotoUrl: map['calleePhotoUrl'] as String?,
      type: callTypeFromString(map['type'] as String? ?? 'audio'),
      status: callStatusFromString(map['status'] as String? ?? 'ended'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      connectedAt: (map['connectedAt'] as Timestamp?)?.toDate(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,
      'calleeId': calleeId,
      'calleeName': calleeName,
      'calleePhotoUrl': calleePhotoUrl,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'connectedAt': connectedAt != null ? Timestamp.fromDate(connectedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }
}

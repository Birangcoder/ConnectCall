import 'call_model.dart';

/// A per-user view of a completed call, used to render the Call History
/// screen (e.g. "Sarah Johnson · Video Call · Today 11:45 AM · 02:35").
class CallHistoryEntry {
  final String callId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final CallType type;
  final CallStatus status;
  final bool isOutgoing;
  final Duration duration;
  final DateTime timestamp;

  const CallHistoryEntry({
    required this.callId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.type,
    required this.status,
    required this.isOutgoing,
    required this.duration,
    required this.timestamp,
  });

  bool get isMissed =>
      status == CallStatus.missed || status == CallStatus.rejected;

  /// Builds a history entry from the caller or callee's point of view.
  factory CallHistoryEntry.fromCall(CallModel call, {required String currentUserId}) {
    final isOutgoing = call.callerId == currentUserId;
    return CallHistoryEntry(
      callId: call.id,
      otherUserId: isOutgoing ? call.calleeId : call.callerId,
      otherUserName: isOutgoing ? call.calleeName : call.callerName,
      otherUserPhotoUrl: isOutgoing ? call.calleePhotoUrl : call.callerPhotoUrl,
      type: call.type,
      status: call.status,
      isOutgoing: isOutgoing,
      duration: call.duration,
      timestamp: call.createdAt,
    );
  }
}

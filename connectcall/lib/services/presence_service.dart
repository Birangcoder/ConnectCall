import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  DatabaseReference? _connectionRef;

  bool _started = false;

  // ---------------------------------------------------------------------------
  // START PRESENCE
  // ---------------------------------------------------------------------------

  Future<void> startPresence() async {
    final user = _auth.currentUser;

    if (user == null || _started) {
      return;
    }

    _started = true;

    final connectedRef = _database.ref('.info/connected');

    _connectionSubscription = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value == true;

      if (!connected) {
        return;
      }

      final uid = user.uid;

      final connectionsRef = _database.ref('presence/$uid/connections');

      final lastSeenRef = _database.ref('presence/$uid/lastSeen');

      // Create a unique connection ID.
      final connectionRef = connectionsRef.push();

      _connectionRef = connectionRef;

      // IMPORTANT:
      // Register disconnect handlers BEFORE marking online.
      await connectionRef.onDisconnect().remove();

      await lastSeenRef.onDisconnect().set(ServerValue.timestamp);

      // Mark this connection as active.
      await connectionRef.set(true);
    });
  }

  // ---------------------------------------------------------------------------
  // STOP PRESENCE
  // ---------------------------------------------------------------------------

  Future<void> stopPresence() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _connectionSubscription?.cancel();

    _connectionSubscription = null;

    if (_connectionRef != null) {
      await _connectionRef!.remove();

      await _connectionRef!.onDisconnect().cancel();

      _connectionRef = null;
    }

    final uid = user.uid;

    await _database.ref('presence/$uid/lastSeen').set(ServerValue.timestamp);

    _started = false;
  }

  // ---------------------------------------------------------------------------
  // WATCH PRESENCE
  // ---------------------------------------------------------------------------

  Stream<PresenceState> watchPresence(String uid) {
    return _database.ref('presence/$uid').onValue.map((event) {
      final value = event.snapshot.value;

      if (value is! Map) {
        return const PresenceState(isOnline: false, lastSeen: null);
      }

      final data = Map<Object?, Object?>.from(value);

      // User is online if at least one connection exists.
      bool isOnline = false;

      final connections = data['connections'];

      if (connections is Map && connections.isNotEmpty) {
        isOnline = true;
      }

      DateTime? lastSeen;

      final timestamp = data['lastSeen'];

      if (timestamp is num) {
        lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
      }

      return PresenceState(isOnline: isOnline, lastSeen: lastSeen);
    });
  }
}

// -----------------------------------------------------------------------------
// PRESENCE STATE
// -----------------------------------------------------------------------------

class PresenceState {
  final bool isOnline;
  final DateTime? lastSeen;

  const PresenceState({required this.isOnline, required this.lastSeen});
}

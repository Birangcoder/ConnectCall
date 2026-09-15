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

    final uid = user.uid;

    final connectedRef = _database.ref('.info/connected');

    _connectionSubscription = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value == true;

      // Firebase has disconnected.
      if (!connected) {
        _connectionRef = null;
        return;
      }

      // Already registered a connection for this session.
      if (_connectionRef != null) {
        return;
      }

      final connectionsRef = _database.ref('presence/$uid/connections');

      final lastSeenRef = _database.ref('presence/$uid/lastSeen');

      // Create ONE unique connection.
      final connectionRef = connectionsRef.push();

      _connectionRef = connectionRef;

      try {
        // Register disconnect handlers BEFORE online.
        await connectionRef.onDisconnect().remove();

        await lastSeenRef.onDisconnect().set(ServerValue.timestamp);

        // Mark this connection online.
        await connectionRef.set(true);
      } catch (e) {
        _connectionRef = null;

        // If setup failed, don't leave this connection
        // as the active local reference.
      }
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

    final uid = user.uid;

    await _connectionSubscription?.cancel();

    _connectionSubscription = null;

    final connectionRef = _connectionRef;

    _connectionRef = null;

    if (connectionRef != null) {
      try {
        await connectionRef.remove();
        await connectionRef.onDisconnect().cancel();
      } catch (_) {}
    }

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

      // User is online only when there is
      // at least one active connection.
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_history_model.dart';
import '../models/call_model.dart';
import 'auth_provider.dart';

final callHistoryProvider = StreamProvider<List<CallHistoryEntry>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;

  if (user == null) {
    return Stream.value(const []);
  }

  return FirebaseFirestore.instance
      .collection('calls')
      .where('participants', arrayContains: user.uid)
      .snapshots()
      .map((snapshot) {
        final entries = snapshot.docs.map((doc) {
          final call = CallModel.fromMap(doc.id, doc.data());

          return CallHistoryEntry.fromCall(call, currentUserId: user.uid);
        }).toList();

        // Newest call first.
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return entries;
      });
});

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_history_model.dart';
import '../models/call_model.dart';
import 'auth_provider.dart';

final callHistoryProvider = StreamProvider<List<CallHistoryEntry>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;

  if (user == null) {
    return const Stream.empty();
  }

  final uid = user.uid;
  final calls = FirebaseFirestore.instance.collection('calls');

  final callerStream = calls.where('callerId', isEqualTo: uid).snapshots();

  final calleeStream = calls.where('calleeId', isEqualTo: uid).snapshots();

  return _combineCallStreams(callerStream, calleeStream, uid);
});

Stream<List<CallHistoryEntry>> _combineCallStreams(
  Stream<QuerySnapshot<Map<String, dynamic>>> callerStream,
  Stream<QuerySnapshot<Map<String, dynamic>>> calleeStream,
  String currentUserId,
) {
  return Stream.multi((controller) {
    QuerySnapshot<Map<String, dynamic>>? callerSnapshot;
    QuerySnapshot<Map<String, dynamic>>? calleeSnapshot;

    void emit() {
      if (callerSnapshot == null || calleeSnapshot == null) {
        return;
      }

      final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      final ids = <String>{};

      for (final doc in callerSnapshot!.docs) {
        if (ids.add(doc.id)) {
          docs.add(doc);
        }
      }

      for (final doc in calleeSnapshot!.docs) {
        if (ids.add(doc.id)) {
          docs.add(doc);
        }
      }

      final entries = docs
          .map((doc) => CallModel.fromMap(doc.id, doc.data()))
          .map(
            (call) =>
                CallHistoryEntry.fromCall(call, currentUserId: currentUserId),
          )
          .toList();

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      controller.add(entries.take(100).toList(growable: false));
    }

    final callerSubscription = callerStream.listen((snapshot) {
      callerSnapshot = snapshot;
      emit();
    }, onError: controller.addError);

    final calleeSubscription = calleeStream.listen((snapshot) {
      calleeSnapshot = snapshot;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await callerSubscription.cancel();
      await calleeSubscription.cancel();
    };
  });
}

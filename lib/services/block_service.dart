import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockService {
  BlockService._();

  static final instance = BlockService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> blockUser(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in');
    }

    if (currentUser.uid == userId) {
      throw Exception('You cannot block yourself');
    }

    await _firestore.collection('users').doc(currentUser.uid).set({
      'blockedUsers': FieldValue.arrayUnion([userId]),
    }, SetOptions(merge: true));
  }

  Future<void> unblockUser(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in');
    }

    await _firestore.collection('users').doc(currentUser.uid).update({
      'blockedUsers': FieldValue.arrayRemove([userId]),
    });
  }

  Future<bool> isUserBlocked(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return false;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final blockedUsers = List<String>.from(
      snapshot.data()?['blockedUsers'] ?? [],
    );

    return blockedUsers.contains(userId);
  }

  Stream<List<String>> blockedUsersStream() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map(
          (snapshot) =>
              List<String>.from(snapshot.data()?['blockedUsers'] ?? []),
        );
  }
}

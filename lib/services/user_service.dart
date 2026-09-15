import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ---------------------------------------------------------------------------
  // WATCH USERS
  // ---------------------------------------------------------------------------

  Stream<List<UserModel>> watchUsers() {
    final currentUid = _auth.currentUser?.uid;

    if (currentUid == null) {
      return const Stream.empty();
    }

    return _users.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList(growable: false);
    });
  }

  // ---------------------------------------------------------------------------
  // CURRENT USER
  // ---------------------------------------------------------------------------

  Stream<UserModel?> watchCurrentUser() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value(null);
    }

    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  // ---------------------------------------------------------------------------
  // GET USER
  // ---------------------------------------------------------------------------

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<UserModel?> getUserById(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return UserModel.fromMap(snapshot.id, snapshot.data()!);
  }

  // ---------------------------------------------------------------------------
  // UPDATE PROFILE
  // ---------------------------------------------------------------------------

  Future<void> updateProfile({
    required String uid,
    required String name,
    String? photoUrl,
  }) async {
    await _users.doc(uid).set({
      'name': name.trim(),
      'photoUrl': photoUrl,
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // SEARCH USERS
  // ---------------------------------------------------------------------------

  Stream<List<UserModel>> searchUsers(String query) {
    final q = query.trim().toLowerCase();

    return watchUsers().map((users) {
      if (q.isEmpty) {
        return users;
      }

      return users
          .where((user) {
            return user.name.toLowerCase().contains(q) ||
                user.email.toLowerCase().contains(q);
          })
          .toList(growable: false);
    });
  }
}

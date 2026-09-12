import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/presence_service.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

// -----------------------------------------------------------------------------
// USER SERVICE
// -----------------------------------------------------------------------------

final userServiceProvider =
Provider<UserService>((ref) {
  return UserService();
});

// -----------------------------------------------------------------------------
// SEARCH QUERY
// -----------------------------------------------------------------------------

final searchQueryProvider =
StateProvider<String>((ref) {
  return '';
});

// -----------------------------------------------------------------------------
// CURRENT USER PROFILE
// -----------------------------------------------------------------------------

final userProfileProvider =
StreamProvider<UserModel?>((ref) {
  final authState =
  ref.watch(authStateProvider);

  final firebaseUser =
      authState.asData?.value;

  if (firebaseUser == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists ||
        snapshot.data() == null) {
      return null;
    }

    return UserModel.fromMap(
      snapshot.id,
      snapshot.data()!,
    );
  });
});

// -----------------------------------------------------------------------------
// ALL USERS
// -----------------------------------------------------------------------------

final usersProvider =
StreamProvider<List<UserModel>>((ref) {
  return ref
      .watch(userServiceProvider)
      .watchUsers();
});

// -----------------------------------------------------------------------------
// LIVE PRESENCE
// -----------------------------------------------------------------------------

final presenceProvider =
StreamProvider.autoDispose
    .family<PresenceState, String>(
      (ref, uid) {
    return PresenceService.instance
        .watchPresence(uid);
  },
);

// -----------------------------------------------------------------------------
// FILTERED USERS
// -----------------------------------------------------------------------------

final filteredUsersProvider =
Provider<AsyncValue<List<UserModel>>>(
      (ref) {
    final users =
    ref.watch(usersProvider);

    final query = ref
        .watch(searchQueryProvider)
        .trim()
        .toLowerCase();

    return users.whenData(
          (list) {
        if (query.isEmpty) {
          return list;
        }

        return list
            .where((user) {
          return user.name
              .toLowerCase()
              .contains(query) ||
              user.email
                  .toLowerCase()
                  .contains(query);
        }).toList(
          growable: false,
        );
      },
    );
  },
);
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError('Account creation failed.');
    }

    await user.updateDisplayName(name.trim());

    // Create Firestore profile.
    await _firestore.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'photoUrl': null,
      'lastSeen': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // ERROR MESSAGES
  // ---------------------------------------------------------------------------

  static String messageForError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with that email.';

        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';

        case 'email-already-in-use':
          return 'An account already exists with that email.';

        case 'weak-password':
          return 'Password is too weak.';

        case 'invalid-email':
          return 'That email address looks invalid.';

        case 'network-request-failed':
          return 'No internet connection. Please try again.';

        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}

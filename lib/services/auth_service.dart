import 'package:firebase_auth/firebase_auth.dart';

/// Admin sign-in with Firebase Authentication (email + password).
class AuthService {
  /// The only account that can see the Model Results page.
  /// Must match the admin user created in Firebase Authentication.
  static const String adminEmail = '2221884@iub.edu.bd';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  static bool isAdmin(User? user) =>
      user != null &&
      (user.email ?? '').toLowerCase() == adminEmail.toLowerCase();

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();
}

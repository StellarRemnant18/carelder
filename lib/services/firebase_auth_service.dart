import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  Future<AuthUser> signInWithGoogle() async {
    final credential = await _firebaseAuth.signInWithProvider(
      GoogleAuthProvider(),
    );
    return _requireUser(credential);
  }

  @override
  Future<AuthUser> signInWithGitHub() async {
    final provider = GithubAuthProvider()..addScope('user:email');
    final credential = await _firebaseAuth.signInWithProvider(provider);
    return _requireUser(credential);
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  AuthUser _requireUser(UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Firebase returned a sign-in result without a user.',
      );
    }

    return _mapUser(user)!;
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      providerId: user.providerData.isEmpty
          ? null
          : user.providerData.first.providerId,
    );
  }
}

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in provider. '
            'Use the provider you originally chose.';
      case 'operation-not-allowed':
        return 'This sign-in provider is not enabled for the Firebase project. '
            'Enable it in Firebase Authentication settings.';
      case 'user-disabled':
        return 'This account has been disabled. Contact the app administrator.';
      case 'network-request-failed':
        return 'Could not reach Firebase. Check your connection and try again.';
      case 'too-many-requests':
        return 'There have been too many attempts. Wait a little and try again.';
      case 'web-context-canceled':
      case 'popup-closed-by-user':
      case 'canceled':
        return 'Sign-in was cancelled.';
      case 'invalid-credential':
        return 'The provider returned an invalid sign-in response. Check the '
            'Firebase provider configuration and try again.';
      default:
        return 'Sign-in could not be completed. Check the provider setup and '
            'try again.';
    }
  }

  return 'Sign-in could not be completed. Check your connection and try again.';
}

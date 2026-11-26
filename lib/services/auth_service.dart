import '../models/auth_user.dart';

abstract interface class AuthService {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithGitHub();

  Future<void> signOut();
}

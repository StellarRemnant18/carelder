class AuthUser {
  const AuthUser({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.providerId,
  });

  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? providerId;
}

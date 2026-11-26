import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_bootstrap.dart';
import 'app_shell.dart';
import 'sign_in_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.authService, this.firebaseInitialized});

  final AuthService? authService;
  final bool? firebaseInitialized;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthService? _authService;
  int _streamVersion = 0;
  bool _isRetryingFirebase = false;
  String? _firebaseError;

  AuthService get _service =>
      _authService ??= widget.authService ?? FirebaseAuthService();

  Future<void> _retryFirebase() async {
    setState(() {
      _isRetryingFirebase = true;
      _firebaseError = null;
    });

    try {
      await FirebaseBootstrap.initialize(AppScope.of(context));
      if (!mounted) return;
      setState(() {
        if (!FirebaseBootstrap.isInitialized) {
          _firebaseError =
              'Firebase is still unavailable. Check this platform’s Firebase '
              'configuration and try again.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _firebaseError =
            'Firebase could not be initialized. Check the platform '
            'configuration and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isRetryingFirebase = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialized =
        widget.firebaseInitialized ?? FirebaseBootstrap.isInitialized;
    if (!initialized) {
      return _FirebaseUnavailablePage(
        isRetrying: _isRetryingFirebase,
        errorMessage: _firebaseError,
        onRetry: _isRetryingFirebase ? null : _retryFirebase,
      );
    }

    return StreamBuilder<AuthUser?>(
      key: ValueKey<int>(_streamVersion),
      stream: _service.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AuthStateErrorPage(
            onRetry: () => setState(() => _streamVersion++),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Semantics(
                label: 'Checking sign-in status',
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return SignInPage(authService: _service);
        }

        return AppShell(user: user, authService: _service);
      },
    );
  }
}

class _FirebaseUnavailablePage extends StatelessWidget {
  const _FirebaseUnavailablePage({
    required this.isRetrying,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isRetrying;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 56,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Firebase is not available',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign-in and protected CaringMate features need Firebase. '
                    'This project currently has Firebase options configured '
                    'for Android only. Configure the target platform before '
                    'continuing.',
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: isRetrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(isRetrying ? 'Retrying...' : 'Retry setup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthStateErrorPage extends StatelessWidget {
  const _AuthStateErrorPage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Could not check your sign-in status. Your account is still '
                'protected.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

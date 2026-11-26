import 'package:carelder/core/app_state.dart';
import 'package:carelder/models/app_models.dart';
import 'package:carelder/models/auth_user.dart';
import 'package:carelder/screens/app_shell.dart';
import 'package:carelder/screens/auth_gate.dart';
import 'package:carelder/screens/notifications_page.dart';
import 'package:carelder/screens/profile_page.dart';
import 'package:carelder/screens/sign_in_page.dart';
import 'package:carelder/services/auth_service.dart';
import 'package:carelder/services/firebase_messaging_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const signedInUser = AuthUser(
    displayName: 'Ada Care',
    email: 'ada@example.com',
    photoUrl: null,
    providerId: 'google.com',
  );

  testWidgets('signed-out users see provider sign-in, not the app shell', (
    tester,
  ) async {
    final controller = AppController();
    final authService = _FakeAuthService();

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: AuthGate(authService: authService, firebaseInitialized: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with GitHub'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('provider buttons invoke the matching auth operation', (
    tester,
  ) async {
    final authService = _FakeAuthService();
    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authService: authService)),
    );

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(authService.googleSignIns, 1);
    expect(find.text('Signed in successfully.'), findsOneWidget);

    await tester.tap(find.text('Continue with GitHub'));
    await tester.pumpAndSettle();
    expect(authService.githubSignIns, 1);
  });

  testWidgets('provider setup failures are shown without exposing raw errors', (
    tester,
  ) async {
    final authService = _FakeAuthService()
      ..googleError = FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'private provider diagnostic',
      );
    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authService: authService)),
    );

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not enabled for the Firebase project'),
      findsOneWidget,
    );
    expect(find.textContaining('private provider diagnostic'), findsNothing);
  });

  testWidgets(
    'authenticated users enter protected tabs and see their account',
    (tester) async {
      final controller = AppController();
      final authService = _FakeAuthService(initialUser: signedInUser);

      await tester.pumpWidget(
        MaterialApp(
          home: AppScope(
            controller: controller,
            child: AuthGate(
              authService: authService,
              firebaseInitialized: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Ada Care'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    },
  );

  testWidgets('sign-out clears in-memory user data after confirmation', (
    tester,
  ) async {
    final controller = AppController()
      ..addWater(250)
      ..addMedication(
        const MedicationEntry(id: 'm1', name: 'Medicine', schedule: 'Daily'),
      )
      ..addNotification(
        AppNotification(
          id: 'n1',
          title: 'Reminder',
          body: 'Test',
          receivedAt: DateTime(2026),
        ),
      );
    final authService = _FakeAuthService(initialUser: signedInUser);

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: Scaffold(
            body: ProfilePage(user: signedInUser, authService: authService),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(authService.signOuts, 1);
    expect(controller.waterIntakeMl, 0);
    expect(controller.medications, isEmpty);
    expect(controller.notifications, isEmpty);
  });

  testWidgets('notifications page requests permission and reports status', (
    tester,
  ) async {
    final controller = AppController();
    final permissionService = _FakeNotificationPermissionService();

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: Scaffold(
            body: NotificationsPage(permissionService: permissionService),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not requested'), findsOneWidget);
    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();

    expect(permissionService.requests, 1);
    expect(find.text('Allowed'), findsOneWidget);
    expect(find.text('Notification permission enabled.'), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.initialUser});

  final AuthUser? initialUser;
  Object? googleError;
  int googleSignIns = 0;
  int githubSignIns = 0;
  int signOuts = 0;

  @override
  Stream<AuthUser?> get authStateChanges =>
      Stream<AuthUser?>.value(initialUser);

  @override
  Future<AuthUser> signInWithGoogle() async {
    googleSignIns++;
    if (googleError != null) throw googleError!;
    return signedInUserForTest;
  }

  @override
  Future<AuthUser> signInWithGitHub() async {
    githubSignIns++;
    return signedInUserForTest;
  }

  @override
  Future<void> signOut() async {
    signOuts++;
  }
}

const signedInUserForTest = AuthUser(
  displayName: 'Ada Care',
  email: 'ada@example.com',
  photoUrl: null,
  providerId: 'google.com',
);

class _FakeNotificationPermissionService
    implements NotificationPermissionService {
  int requests = 0;
  AuthorizationStatus status = AuthorizationStatus.notDetermined;

  @override
  Future<AuthorizationStatus> getPermissionStatus() async => status;

  @override
  Future<AuthorizationStatus> requestPermission() async {
    requests++;
    status = AuthorizationStatus.authorized;
    return status;
  }
}

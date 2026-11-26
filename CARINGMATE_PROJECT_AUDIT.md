# CaringMate Project Audit

**Audit date:** 2026-11-26  
**Scope:** Read-only inspection of the current `D:\carelder` working tree. This report is the only requested deliverable created by the audit; no application source or configuration was edited. Existing worktree changes were present before inspection and are treated as part of the audited state.

## Executive summary

CaringMate is a Flutter prototype with a cohesive set of care-oriented screens, an in-memory application controller, an Android Health Connect permission bridge, and a working Geoapify hospital-search path when configured. Several interfaces explicitly identify example data and inactive functions.

The project is **not yet an authenticated, persistent health application**:

- Firebase Core and several operational SDKs are initialized on Android, but Firebase Authentication and Cloud Firestore have no application call sites. There is no sign-in, registration, account session, or user data flow.
- Health Connect can be checked and can request step/heart-rate read permissions, but no health records are read. The visible vital values are hard-coded samples.
- Medication, hydration, theme, and notification state are in memory and disappear when the process restarts. Medication entries do not schedule alarms.
- Hospital search has a real location → Geoapify places request → map/list flow, but requires a compile-time key and device location; it has no address search or directions flow.
- Android is the only configured Firebase platform. Other generated Flutter targets exist, but Firebase initialization is unsupported there.
- The test suite is still the Flutter counter smoke test and does not exercise CaringMate.

Do not treat the sample health measurements as a user’s actual health data. Before release, prioritize platform/configuration and privacy review, real authentication and persistence, Health Connect record reading, and focused tests.

## Architecture

### Application composition

`[lib/main.dart](lib/main.dart)` initializes Flutter bindings, creates one `AppController`, invokes `FirebaseBootstrap.initialize`, and then launches the app. Firebase initialization failure is logged and startup continues.

`[lib/app.dart](lib/app.dart)` builds a `MaterialApp` with light/dark themes and `AppShell` as its home. There is no authentication gate, named-route table, or deep-link flow.

`[lib/core/app_state.dart](lib/core/app_state.dart)` contains the app-wide `ChangeNotifier` and `AppScope`. State is held only in process memory; no database, preferences, or repository layer is present. `IndexedStack` preserves the five main tab widgets while navigating between them.

`[lib/core/app_theme.dart](lib/core/app_theme.dart)` defines light and dark Material 3 themes. Several screens and reusable widgets still use fixed light colors, so dark-mode coverage is incomplete.

### Source inventory

| Area | Existing contents |
|---|---|
| Startup/configuration | `[lib/main.dart](lib/main.dart)`, `[lib/app.dart](lib/app.dart)`, `[lib/firebase_options.dart](lib/firebase_options.dart)`, `[firebase.json](firebase.json)`, `[pubspec.yaml](pubspec.yaml)` |
| Core | `[lib/core/app_state.dart](lib/core/app_state.dart)`, `[lib/core/app_theme.dart](lib/core/app_theme.dart)` |
| Models | `[lib/models/app_models.dart](lib/models/app_models.dart)` (`MedicationEntry`, `AppNotification`); `[lib/models/hospital_place.dart](lib/models/hospital_place.dart)` (`HospitalPlace`) |
| Screens | `[lib/screens/app_shell.dart](lib/screens/app_shell.dart)` and the nine feature pages listed below |
| Services | `[lib/services/firebase_bootstrap.dart](lib/services/firebase_bootstrap.dart)`, `[lib/services/geoapify_places_service.dart](lib/services/geoapify_places_service.dart)`, `[lib/services/health_connect_service.dart](lib/services/health_connect_service.dart)` |
| Configuration | `[lib/config/geoapify_config.dart](lib/config/geoapify_config.dart)` |
| Shared UI | `[lib/widgets/app_widgets.dart](lib/widgets/app_widgets.dart)` |
| Tests | `[test/widget_test.dart](test/widget_test.dart)`; no integration or service tests found |
| Android | `[android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)`, `[android/app/src/main/kotlin/com/example/carelder/MainActivity.kt](android/app/src/main/kotlin/com/example/carelder/MainActivity.kt)`, `[android/app/build.gradle.kts](android/app/build.gradle.kts)` plus Gradle, resources, and Firebase Android configuration |
| Other platforms | Standard Flutter iOS, web, Windows, Linux, and macOS runner files are present. They do not have equivalent Health Connect support; Firebase options are only provided for Android. |

`[README.md](README.md)` is still the generic Flutter starter guide; it does not explain the app, configuration, or run/test setup.

### Screens, widgets, services, models, and functions

**Main navigation:** `AppShell` displays `DashboardPage`, `HealthPage`, `CarePage`, `ServicesPage`, and `ProfilePage` as five bottom-navigation destinations.

**Screens and principal interactions**

- `DashboardPage`: greeting/top bar, notifications shortcut, sample health cards, quick actions, connection-status panel, and `_showEmergencyNotice`. Its nested widgets are `_TopBar`, `_WelcomeCard`, `_QuickActions`, `_QuickActionItem`, and `_ConnectionsCard`.
- `HealthPage`: sample measurement cards and device/Health Connect connection tiles. `_connectHealthConnect` checks SDK availability, requests permissions, and reports the result; it does not read or display records.
- `CarePage`: opens medication and hydration pages and shows an unimplemented caregiver-network state. `_CareFeatureCard` is its shared local card.
- `ServicesPage`: opens hospital search, notifications, and settings. `_ServiceItem` is its list-row widget.
- `ProfilePage`: placeholder profile, notification/settings links, privacy information dialog, and a working in-memory theme switch. `_ProfileTile` is its shared row.
- `SettingsPage`: changes the in-memory `ThemeMode` and displays static privacy, credential, and cloud-storage notes. `_PrivacyNote` formats those notes.
- `HospitalSearchPage`: manages location permission, current position, radius and optional name filters, Geoapify results, FlutterMap tiles/markers, and selection. Its principal methods are `_findNearbyHospitals`, `_selectHospital`, `_buildMap`, `_mapPlaceholder`, `_buildRadiusSelector`, and `_buildHospitalCard`.
- `MedicationPage`: adds, checks off, and removes `MedicationEntry` items in memory. `_MedicationDialogState` validates name/schedule/notes and `_save` returns a new item.
- `HydrationPage`: adds fixed 150/250/500 ml amounts and confirms a session reset. `_WaterButton` triggers the increments.
- `NotificationsPage`: displays in-memory notifications, marks one/all read, clears all, and formats timestamps using `_formatDate`.

**Shared widgets:** `PageHeader`, `SectionHeading`, `SurfaceCard`, `StatusPill`, `DemoDataNotice`, `EmptyState`, `HealthMetricCard`, `IntegrationTile`, and `showInfoDialog` are in `[lib/widgets/app_widgets.dart](lib/widgets/app_widgets.dart)`.

**State/model operations:** `AppController` exposes `setThemeMode`, `addWater`, `resetWater`, `addMedication`, `toggleMedication`, `removeMedication`, `addNotification`, `markNotificationRead`, `markAllNotificationsRead`, and `clearNotifications`. It owns only the active process’s lists and counter.

**Integration APIs:**

- `FirebaseBootstrap.initialize` sequences Firebase Core, App Check, Crashlytics, Performance, Remote Config, Messaging, and a startup Analytics event. Helpers are `_initializeAppCheck`, `_initializeCrashlytics`, `_initializePerformance`, `_initializeRemoteConfig`, `_initializeMessaging`, and `logEvent`.
- `GeoapifyPlacesService.searchHospitals` validates the key/radius, calls the Geoapify Places endpoint, parses coordinates and labels, calculates/sorts distances, and maps errors to `GeoapifyException`. `_asMap`, `_asDouble`, and `dispose` support it.
- `HealthConnectService.checkAvailability` and `requestPermissions` call the Android method channel. These are permission/availability operations only.
- Android `MainActivity` implements channel methods `checkAvailability` and `requestPermissions`, requests step and heart-rate permissions, and returns the granted-permission state through `onActivityResult`.

## Feature status and navigation connections

| Feature | Status | Current UI/service connection |
|---|---|---|
| Five-tab navigation | Implemented | `AppShell` switches among the five root pages using an `IndexedStack`. |
| Hospital search | Partially implemented / functional when configured | Dashboard quick action and Services page open it. Search requests location and calls Geoapify; map markers and result cards select/focus a hospital. |
| Health Connect | Partially implemented | Health page calls the Android method channel to check availability/request permissions. No actual record query or sync exists. |
| Health measurements | Placeholder | Dashboard and Health show fixed sample values, clearly labeled as examples in the current UI. |
| Medication list | Local prototype | Dashboard/Care open it; add, toggle, and remove work only in the current process. No dose notification is scheduled. |
| Hydration log | Local prototype | Dashboard/Care open it; manual increments/reset work only in the current process. Progress uses a stated example reference, not a medical target. |
| Notifications | Foreground-only prototype | Dashboard, Services, and Profile open the list. Firebase foreground messages are added in memory. Background/terminated delivery, persistence, actions, and permission onboarding are absent. |
| Authentication/profile | Missing | No sign-in or registration page, authentication service call, current-user observer, sign-out, or real profile data. The profile editing action opens an informational dialog. |
| Firestore | Missing application flow | The package is a dependency, but no read/write, model mapping, repository, security rules, or use of `collection`/`doc` exists in app source. |
| Emergency SOS | Not implemented | Quick action only opens a warning. It does not call emergency services, alert caregivers, or share location. |
| DaFit / Google Fit | Informational only | Health tiles explain that the source/bridge is not verified; no SDK or data flow is implemented. |
| Caregiver network | Missing | UI explicitly says account linking is not configured. |
| Theme | Partially implemented | Light/dark/system selection works in memory, but it resets on restart and fixed-color components reduce dark-theme consistency. |

**Route connections observed:** Dashboard → Notifications, Hospital Search, Medication, Hydration, and an SOS warning. Care → Medication and Hydration. Services → Hospital Search, Notifications, and Settings. Profile → Notifications, Settings, privacy dialog, and theme control. Health → Health Connect permission flow and informational DaFit/Google Fit dialogs. Hospital selection only updates the map/list selection; no directions, call, or external map action is connected.

## Integration findings

### Firebase Authentication and Firestore

- `firebase_auth`, `google_sign_in`, and `cloud_firestore` are declared dependencies, but repository search found no authentication or Firestore application calls. **Sign-in and registration are not connected to the UI.**
- Firebase options provide only Android configuration. `DefaultFirebaseOptions.currentPlatform` throws for iOS, macOS, Windows, Linux, and web. The bootstrap catches initialization failure and returns; the UI still starts without Firebase and does not show a configuration error.
- Firebase Core, App Check, Crashlytics, Performance, Remote Config, Messaging, and Analytics have bootstrap calls. Analytics currently logs only the startup event. Remote Config is fetched but no defaults/values are consumed. Performance is enabled, and Crashlytics is assigned to `FlutterError.onError`.
- Messaging listens to `FirebaseMessaging.onMessage` and reads a token without storing it. There is no notification permission flow, top-level background message handler, `onMessageOpenedApp`/initial-message navigation, or local-notification display. `flutter_local_notifications` has no app-source usage.
- Several setup errors are caught and printed while the app proceeds. This allows graceful startup but leaves the user without a clear indication that Firebase-dependent functionality is unavailable.
- Before adding user/health data, design the authentication/session model and Firestore authorization rules first. Client configuration identifiers are not server secrets; API-key restrictions, App Check enforcement, and server-side authorization still require verification. No key/token values are reproduced in this report.

### Geoapify and hospital search

- `[lib/config/geoapify_config.dart](lib/config/geoapify_config.dart)` reads `GEOAPIFY_API_KEY` through `String.fromEnvironment`; the app must be launched/built with a Dart define (or an explicitly wired define file). A `local.properties` file by itself does not automatically populate this Dart environment value.
- The service requests `healthcare.hospital` features around the current GPS coordinates, optionally filters by a name, and sorts parsed results by computed distance. The screen offers 2/5/10/20 km radii and uses `flutter_map` with Geoapify raster tiles and hospital/current-location markers.
- Location services and runtime location permission are checked before the search. Denied and permanently denied cases are reported in the screen.
- The map is initialized at a fixed India-area default center until current location is fetched. Search is GPS-only; there is no manual address/place lookup, route/directions, facility call action, or verification of opening status/services.
- The Geoapify key is sent to the client and appears in service/tile request URLs. Treat it as a restricted public client key: limit it to required APIs/quotas and appropriate app origins/controls, rotate it if exposed beyond intended use, and never place a private server credential here. The service’s catch-all includes the underlying error text in the displayed exception; check that errors cannot expose a full request URI/key.
- `GeoapifyPlacesService` closes `_client` in `dispose` even when the optional client was injected. Current screen construction owns its default client, but callers that inject/share a client could have it closed unexpectedly.
- Search results are cleared before each attempt. A later permission/network/API failure therefore removes the preceding result list. There is no explicit location timeout configured.

### Health Connect and native Android

- Android Gradle includes `androidx.health.connect:connect-client`; the main manifest declares coarse/fine location and Health Connect read permissions for steps and heart rate, plus Health Connect package visibility.
- The native bridge reports SDK availability and requests those two permissions. Flutter considers the connection “Access allowed” only when both are granted.
- No `HealthConnectClient` instance is created, no `readRecords`/aggregate query exists, and the permission results are not connected to the sample cards. There is no check for already-granted/revoked access on later visits, data freshness/source display, or user-visible read error state.
- The channel’s permission flow uses deprecated `startActivityForResult`/`onActivityResult` and stores a pending method result in the Activity. Activity recreation/process death while the Health Connect sheet is open is not handled. Convert to the Activity Result API and make the operation lifecycle-safe when implementing record reads.
- The current health page exposes hard-coded heart rate, SpO₂, blood pressure, and steps, while requested permissions cover only steps and heart rate. This mismatch must be resolved before presenting live readings: define supported record types, actual record availability, units, timestamps, and empty/error states. Do not imply that unavailable values came from Health Connect.
- This custom integration is Android-only; other platform UI should clearly state unsupported/unavailable rather than assuming equivalent synchronization.

## Incomplete behavior, bugs, and architectural risks

### UI/product issues

- Sample vitals and device/caregiver statuses are static. The UI does identify example measurements and unverified connections, but future live data needs clear source/time labels and must replace—not silently coexist with—these samples.
- `ServicesPage` still describes hospital search as “prepared for Maps integration” although a Geoapify map/search flow is now present.
- Fixed colors in cards, notices, text, and labels do not consistently follow the theme; dark mode should be reviewed screen by screen.
- Health measurement cards have fixed heights and mostly fixed-color presentation. Check smaller devices, larger text/display scale, landscape/tablet, and accessibility contrast/tap targets.
- The profile, privacy/permission, notification, and integration actions often show static informational dialogs rather than settings or connected account flows. The SOS action is intentionally a nonfunctional warning, not an emergency feature.
- Static text and generic app identity remain in starter files; product wording, platform labels, and app identity should be aligned before release.

### Backend/data issues

- There is no account/session model or authentication UI, no persistent repository, and no backend ownership boundary. All app-managed data is local process memory.
- There are no Firestore rules/indexes or backend functions in the tracked project. Do not begin health/caregiver cloud storage until access control, consent, retention, deletion/export, and least-privilege rules are specified.
- Medication “schedule” is free text and has no notification trigger; it should not be marketed as an alarm/reminder until scheduling, permissions, time zones, recurrence, reboot behavior, and cancellation are implemented/tested.
- FCM is not yet a full push-notification product flow; foreground messages alone are not sufficient for delivery/navigation requirements.

### Native/platform/release issues

- Android namespace/application ID remains the generic `com.example.carelder`; Android display label is `carelder` while in-app branding is CaringMate.
- Android release builds still use debug signing configuration. Add production signing outside source control before distributing a release.
- Firebase app options are Android-only despite the presence of multiple Flutter platform runners.
- The custom Health Connect channel requires Android-specific lifecycle, permission-revocation, and device/API-level testing.
- The root `local.properties` is untracked in the pre-audit worktree; its contents were intentionally not inspected or copied. Keep local machine configuration and any credentials out of version control. An Android heap dump (`android/java_pid23068.hprof`) is also present in the workspace but is not tracked; heap dumps can contain sensitive runtime data and should not be distributed.

### Code quality and tests

- Flutter analyzer completed without errors but exited nonzero with **18 info-level lint/deprecation findings**: deprecated Material state APIs, `withOpacity`, radio tile APIs, Firebase Messaging `getToken`, style lints, and an unnecessary underscore use. They are cleanup items, not reported analyzer errors.
- `flutter test` passes, but the only test is a standalone counter smoke test and exercises none of the application.
- Related behavior is concentrated in large page widgets and a single global in-memory controller. A repository/use-case layer would improve testability as persistence is introduced; do not refactor unrelated UI before the data boundaries are established.
- `flutter_local_notifications`, Authentication, Firestore, and Google Sign-In are dependencies without corresponding app-source behavior.

## Missing files/functions and recommended additions

These are recommendations, not claims that a particular design has already been selected:

1. **Authentication:** `lib/features/auth/presentation/sign_in_page.dart`, `registration_page.dart`, and `password_reset_page.dart`; `lib/features/auth/data/auth_repository.dart` (Firebase Auth adapter), input validation, auth-state routing, and sign-out. Add provider sign-in only if required.
2. **Profile and persistence:** `lib/features/profile/domain/user_profile.dart`, `lib/features/profile/data/profile_repository.dart`, and repositories for medication, hydration, and notification preferences. Choose local persistence vs. Firestore per data type and define sync/offline/conflict behavior.
3. **Firestore security:** `firestore.rules`, `firestore.indexes.json` as needed, and optionally `functions/` for trusted server work. Rules and tests must exist before client data writes.
4. **Health Connect reads:** an explicit Dart data model/repository and service operations for checking current grants and reading the approved record types; corresponding Kotlin read/aggregate operations and lifecycle-safe Activity Result permission handling. Keep UI permissions/data labels aligned with the actual supported types.
5. **Messaging/alarms:** a top-level FCM background handler, notification permission/onboarding flow, background/opened/initial-message routing, and a notification/scheduling service. Define whether medication reminders are local-only or server-triggered.
6. **Testing:** replace the starter-only test emphasis with focused controller/widget tests, Geoapify parsing/error tests using a fake HTTP client, Firebase adapter tests with fakes/emulators, and Android Health Connect permission/read tests on supported devices/emulators.
7. **Product/release configuration:** project-specific `README.md` run/config instructions, per-platform Firebase setup where supported, privacy policy/consent surfaces, release signing and package identity configuration, and a safe documented Dart-define workflow that does not commit keys.

## Prioritized implementation roadmap

### P0 — Safety, configuration, and release boundaries

1. Keep vitals clearly marked as examples until real values are read; keep SOS explicitly unavailable until tested end to end.
2. Decide supported platforms and configure Firebase options for each supported target, or prevent unsupported targets from presenting Firebase-backed features. Make initialization failure observable in development and appropriately handled in production.
3. Restrict/rotate the Geoapify client key as appropriate, document its Dart-define setup without publishing the value, and sanitize errors so request URLs are not shown.
4. Define privacy/consent, retention/deletion, and access policy before storing account, caregiver, or health information. Replace debug release signing and generic app identity before distribution.

### P1 — Authentication and data foundation

1. Add sign-in/registration/password reset and auth-state navigation; connect sign-out and profile display.
2. Define data ownership and repositories, then implement the selected persistence approach. Add Firestore rules/emulator tests before enabling writes.
3. Persist local-only preferences and non-sensitive tracker state only after the data model and reset/account behavior are agreed.

### P2 — Real health and location data

1. Implement lifecycle-safe Health Connect permissions and actual step/heart-rate reads for an agreed time range; handle denied/revoked/empty/error states.
2. Map only supported records to UI and identify source, timestamp, units, and freshness. Remove or distinctly isolate unsupported sample values such as SpO₂/blood pressure.
3. Exercise Android API levels, Health Connect unavailable/update-required states, partial grants, revoked grants, and process recreation.
4. Improve hospital search configuration, errors/timeouts, accessibility, and add directions/contact actions only after their UX and data accuracy are specified.

### P3 — Notifications, reminders, and caregiver features

1. Implement foreground/background/terminated FCM flows and user notification permission/settings.
2. Decide and implement reliable medication schedule notifications (or keep medication as a non-reminder list with clear wording).
3. Build caregiver linking only with authentication, explicit consent, roles, revocation, auditability, and tested backend authorization.
4. Implement an emergency workflow only after product, legal, provider, and device testing; do not equate an SOS button with emergency dispatch.

### P4 — Design, accessibility, and polish

1. Use **Figma** for the redesign work: first map task flows and states for authentication, dashboard/health data, hospital search/results, medication/hydration, and profile/settings. Include loading, permission denied, empty, offline/error, dark theme, and accessibility states in the design.
2. Use **Copilot** for ordinary, well-specified implementation work: widgets, forms, service adapters, repositories, straightforward navigation, tests, and analyzer cleanup.
3. Reserve **Antigravity** for investigations that need deeper cross-layer exploration—especially Health Connect lifecycle/data semantics, Firebase rules and caregiver access, or a safety-critical emergency workflow. It is not needed for routine layout or isolated widget changes.
4. Validate Figma decisions against small phones, large text, tablet/web layouts, color contrast, semantic labels, and realistic error states before release.

## Verification performed

- Read-only source/configuration review of the current working tree; credential/config file contents containing possible keys were not included in this report.
- `flutter analyze`: no analyzer errors; 18 info-level lint/deprecation findings; command exit status was nonzero due to those findings.
- `flutter test`: passed (one counter smoke test; no CaringMate behavior covered).

## Worktree note

The worktree already contained modified/untracked files before the audit, including changes under Android Gradle/manifest/Kotlin, Health and hospital screens, Geoapify/Health Connect configuration and services, dependencies, generated plugin registrants, and a root `local.properties`. These pre-existing changes were not reverted or edited. The audit report was added at the user's request.

---

## Follow-up: UI/service connectivity review

**Follow-up date:** 2026-11-26  
This section supersedes earlier statements above that Firebase Authentication had no UI or that no authenticated route existed. The review added a Firebase auth gate and provider UI while preserving the previous feature implementations.

### Current implementation status

| Feature/service | Current classification | User-facing access |
|---|---|---|
| Google sign-in | Implemented in UI and connected to Firebase Auth; provider activation/configuration is externally dependent | Initial sign-in screen; Firebase native `GoogleAuthProvider` flow |
| GitHub sign-in | Implemented in UI and connected to Firebase Auth; OAuth app/provider configuration is externally dependent | Initial sign-in screen; Firebase native `GithubAuthProvider` flow requests `user:email` |
| Session/protected app | Implemented | Firebase `authStateChanges` gates all five app tabs. A session-state error blocks the app shell and offers retry. |
| Account display/sign-out | Implemented | Profile tab displays provider account details; confirmed sign-out clears in-memory care data and returns through the auth gate |
| FCM permission | Permission request/status UI implemented; delivery still partial | Notifications page can inspect/request device permission; existing list is available from Dashboard, Services, and Profile |
| Unread notification count | Implemented | Dashboard notification action now shows the unread count |
| Hospital search / Geoapify | Implemented when key and location access are available | Dashboard quick action and Services page; earlier search/map constraints remain |
| Health Connect | Partially implemented | Health tab exposes availability/permissions only; no record-reading function exists |
| Firebase Analytics | Startup event only; no user-facing control is appropriate | Instrumentation runs at startup; no analytics dashboard or event controls |
| Crashlytics, App Check, Performance | Background infrastructure; no user-facing controls are appropriate | Configured through bootstrap; runtime/service activation is not separately surfaced per SDK |
| Remote Config | Configured/fetched but no values are consumed by a user feature | No UI feature to expose until remote parameters are defined |
| Firestore | Dependency only; no repository/read/write/rules implementation | No UI is added because there is no functional Firestore feature to connect |
| Medication, hydration, theme, notification list | Partially implemented, local-only | Existing UI is accessible; data remains in memory and medication entries do not schedule alarms |
| Emergency SOS, caregiver linking, profile editing | Missing or placeholder | Existing warning/information UI remains explicit; no unsafe or success-shaped fake functionality was added |

### Authentication routing and behavior added

- Firebase initialization remains before `runApp`. When Firebase Core is unavailable, the app now presents an explanatory setup/retry screen rather than entering the app shell.
- `AuthGate` listens to Firebase Auth session changes. Signed-out users see Google/GitHub buttons; signed-in users enter `AppShell`. All existing app tabs are below this gate.
- Provider calls use FlutterFire's native `signInWithProvider` API. Errors are mapped to user-safe messages; raw provider diagnostics are not displayed.
- Profile displays the signed-in provider identity, offers confirmed sign-out, and clears in-memory medications, hydration, and notifications after successful sign-out.
- Android Firebase configuration contains an Android OAuth client matching the configured application ID. This confirms local package/config alignment only; it does **not** prove that the Google provider is enabled, signing fingerprints are registered, or a real account flow succeeds.

### External setup still required for real provider sign-in

1. In Firebase Console → Authentication → Sign-in method, enable **Google** and **GitHub** for the same Firebase project used by the Android app.
2. **Google / Android:** register the debug and release signing certificate SHA-1 (and SHA-256 where required) in Firebase project settings, verify the Android OAuth client corresponds to the installed application ID, then download/regenerate the matching `google-services.json`. The repository does not establish which signing fingerprints are registered.
3. **GitHub:** create/configure a GitHub OAuth App, enter its client ID and client secret in Firebase Console's GitHub provider settings, and set its authorization callback URL to the exact handler URL Firebase Console provides. Keep the client secret only in Firebase Console; do not put it in Flutter code, assets, or Dart defines.
4. Configure Firebase options for iOS/web/other targets before enabling sign-in there. The current `DefaultFirebaseOptions` supports Android only, so other targets intentionally stop at the Firebase-unavailable screen.
5. If App Check is enforced, register valid debug/test and production Play Integrity configuration for the corresponding builds.

Provider toggles, OAuth client secrets, callback-domain authorization, and certificate fingerprints are Firebase/GitHub Console state and cannot be verified from this repository. No real Google or GitHub account sign-in was attempted.

### Files changed for the follow-up

- `[lib/models/auth_user.dart](lib/models/auth_user.dart)`, `[lib/services/auth_service.dart](lib/services/auth_service.dart)`, and `[lib/services/firebase_auth_service.dart](lib/services/firebase_auth_service.dart)`: account model, injectable auth contract, native Google/GitHub provider calls, session mapping, sign-out, and safe auth-error messages.
- `[lib/screens/auth_gate.dart](lib/screens/auth_gate.dart)` and `[lib/screens/sign_in_page.dart](lib/screens/sign_in_page.dart)`: Firebase availability/retry, auth-state routing, responsive provider buttons, loading, and error states.
- `[lib/app.dart](lib/app.dart)` and `[lib/screens/app_shell.dart](lib/screens/app_shell.dart)`: make authentication the app entry boundary and pass the current session to the profile tab.
- `[lib/screens/profile_page.dart](lib/screens/profile_page.dart)` and `[lib/core/app_state.dart](lib/core/app_state.dart)`: display account information, confirm sign-out, and clear session-local user data.
- `[lib/services/firebase_messaging_service.dart](lib/services/firebase_messaging_service.dart)` and `[lib/screens/notifications_page.dart](lib/screens/notifications_page.dart)`: expose notification permission status/request with loading, denied, error, and success states while retaining the existing message list.
- `[lib/screens/dashboard_page.dart](lib/screens/dashboard_page.dart)`: add unread notification badge and increase metric-card height on wide layouts to avoid overflow found by widget testing.
- `[lib/screens/services_page.dart](lib/screens/services_page.dart)`: replace stale “prepared for Maps integration” description with the current Geoapify-backed behavior.
- `[test/auth_flow_test.dart](test/auth_flow_test.dart)`: cover signed-out/signed-in routing, provider button dispatch, safe provider errors, sign-out data clearing, and permission UI.
- This report: appended this follow-up and superseded the old authentication status above.

### Verification and remaining caveats

- `flutter test`: passed, **7 tests** total (the existing starter smoke test plus six auth/notification flow tests using fakes).
- `flutter analyze --no-fatal-infos`: passed with no errors; **17 info-level** pre-existing deprecation/style findings remain.
- `flutter build apk --debug`: succeeded. Gradle emitted a Flutter warning that several Firebase plugins still apply the legacy Kotlin Gradle Plugin and may need updates for a future Flutter release.
- `flutter run --no-resident -d emulator-5554`: Android app installed and launched; startup logs showed Firebase/Flutter initialization. No provider account was used.
- Google/GitHub authentication is verified at the code/UI-routing level only. End-to-end OAuth remains unverified until Firebase Console provider setup, signing configuration, and test accounts are available.
- Push permission can now be requested in-app, but this does not add a trusted backend token-registration flow, background data-message handling, or notification-open routing. The UI states these limitations.
- `google_sign_in` remains declared but is not used by the new auth path; Firebase's native provider API is used consistently for both providers.

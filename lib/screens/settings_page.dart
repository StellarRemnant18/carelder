import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../widgets/app_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SectionHeading(
            title: 'Appearance',
            subtitle: 'Choose how CaringMate looks on this device',
          ),
          SurfaceCard(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('System default'),
                  value: ThemeMode.system,
                  groupValue: app.themeMode,
                  onChanged: (value) {
                    if (value != null) app.setThemeMode(value);
                  },
                ),
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: app.themeMode,
                  onChanged: (value) {
                    if (value != null) app.setThemeMode(value);
                  },
                ),
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: app.themeMode,
                  onChanged: (value) {
                    if (value != null) app.setThemeMode(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeading(
            title: 'Privacy and data',
            subtitle: 'Important implementation requirements',
          ),
          const SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrivacyNote(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Health data permissions',
                  body:
                      'Request only the Health Connect record types required '
                      'for a user-visible feature. Explain why each permission '
                      'is needed and allow access to be revoked.',
                ),
                Divider(height: 24),
                _PrivacyNote(
                  icon: Icons.lock_outline,
                  title: 'Credentials and API keys',
                  body:
                      'Do not embed private server credentials, OAuth client '
                      'secrets or unrestricted API keys in the Flutter app.',
                ),
                Divider(height: 24),
                _PrivacyNote(
                  icon: Icons.cloud_outlined,
                  title: 'Cloud storage',
                  body:
                      'Do not upload every health record by default. Define '
                      'the purpose, user consent, retention and Firestore '
                      'security rules before storing health information.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const DemoDataNotice(),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => showInfoDialog(
              context,
              title: 'About CaringMate',
              message:
                  'CaringMate is a development prototype. Some screens and '
                  'Firebase services are present, but native health, maps, '
                  'device and emergency integrations must be implemented and '
                  'tested before release.',
            ),
            icon: const Icon(Icons.info_outline),
            label: const Text('About this application'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1769AA)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

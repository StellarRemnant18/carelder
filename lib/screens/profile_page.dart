import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../widgets/app_widgets.dart';
import 'notifications_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: [
        const PageHeader(
          title: 'Profile',
          subtitle: 'Account and application preferences',
        ),
        SurfaceCard(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFDDEBFA),
                child: Icon(Icons.person, size: 42, color: Color(0xFF1769AA)),
              ),
              const SizedBox(height: 12),
              Text(
                'CaringMate user',
                style: TextStyle(
                  fontSize: 19,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Profile details are not configured',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  title: 'Profile editing',
                  message:
                      'Connect Firebase Authentication and a secure profile '
                      'repository before enabling personal profile editing.',
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading(title: 'Application'),
        _ProfileTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
          ),
        ),
        const SizedBox(height: 8),
        _ProfileTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy and permissions',
          onTap: () => showInfoDialog(
            context,
            title: 'Privacy and permissions',
            message:
                'Health Connect permissions should be requested only for data '
                'types the app genuinely needs. Users must be able to review '
                'and revoke access in Android settings.',
          ),
        ),
        const SizedBox(height: 8),
        _ProfileTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading(title: 'Display'),
        SurfaceCard(
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark theme'),
            subtitle: const Text('Change the appearance of CaringMate'),
            value: app.themeMode == ThemeMode.dark,
            onChanged: (enabled) {
              app.setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
        const SizedBox(height: 18),
        const DemoDataNotice(),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'CaringMate · Development build',
            style: TextStyle(color: Colors.black38, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF1769AA)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
      ),
    );
  }
}

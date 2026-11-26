import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/app_widgets.dart';
import 'notifications_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user, required this.authService});

  final AuthUser user;
  final AuthService authService;

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
                user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!
                    : 'CaringMate user',
                style: TextStyle(
                  fontSize: 19,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ??
                    'Signed in with ${_providerLabel(user.providerId)}',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  title: 'Profile editing',
                  message:
                      'Your account name and email come from your sign-in '
                      'provider. Editing additional profile details requires '
                      'a secure profile repository, which is not configured.',
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
              const SizedBox(height: 8),
              _SignOutButton(authService: authService),
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

String _providerLabel(String? providerId) {
  switch (providerId) {
    case 'google.com':
      return 'Google';
    case 'github.com':
      return 'GitHub';
    default:
      return 'your account';
  }
}

class _SignOutButton extends StatefulWidget {
  const _SignOutButton({required this.authService});

  final AuthService authService;

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final controller = AppScope.of(context);
    setState(() => _isSigningOut = true);
    try {
      await widget.authService.signOut();
      controller.clearSessionData();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isSigningOut ? null : _signOut,
      icon: _isSigningOut
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout),
      label: Text(_isSigningOut ? 'Signing out...' : 'Sign out'),
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

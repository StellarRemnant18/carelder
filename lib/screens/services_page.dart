import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';
import 'hospital_search_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: [
        const PageHeader(
          title: 'Services',
          subtitle: 'Tools and application utilities',
        ),
        _ServiceItem(
          icon: Icons.local_hospital_rounded,
          color: const Color(0xFF347AC5),
          title: 'Hospital search',
          description:
              'Hospital search interface prepared for Maps integration.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const HospitalSearchPage()),
          ),
        ),
        const SizedBox(height: 11),
        _ServiceItem(
          icon: Icons.notifications_active_outlined,
          color: const Color(0xFF8B69C7),
          title: 'Notifications',
          description: 'Review messages received by the app.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
          ),
        ),
        const SizedBox(height: 11),
        _ServiceItem(
          icon: Icons.settings_outlined,
          color: const Color(0xFF607D8B),
          title: 'Settings',
          description: 'Theme, privacy information and prototype settings.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
          ),
        ),
        const SizedBox(height: 18),
        const DemoDataNotice(),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

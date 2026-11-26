import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'hospital_search_page.dart';
import 'hydration_page.dart';
import 'medication_page.dart';
import 'notifications_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 800 ? 4 : 2;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TopBar()),
        SliverToBoxAdapter(child: _WelcomeCard()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
          sliver: const SliverToBoxAdapter(child: DemoDataNotice()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          sliver: const SliverToBoxAdapter(
            child: SectionHeading(
              title: 'Health overview',
              subtitle: 'Example readings · not connected to your watch',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate(<Widget>[
              HealthMetricCard(
                title: 'Heart rate',
                value: '72',
                unit: 'BPM',
                icon: Icons.favorite_rounded,
                color: Color(0xFFE85D75),
              ),
              HealthMetricCard(
                title: 'Blood oxygen',
                value: '98',
                unit: '% SpO₂',
                icon: Icons.air_rounded,
                color: Color(0xFF269B83),
              ),
              HealthMetricCard(
                title: 'Blood pressure',
                value: '120/80',
                unit: 'mmHg',
                icon: Icons.monitor_heart_rounded,
                color: Color(0xFF477ED4),
              ),
              HealthMetricCard(
                title: 'Steps today',
                value: '5,421',
                unit: 'steps',
                icon: Icons.directions_walk_rounded,
                color: Color(0xFFE49A36),
              ),
            ]),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.20,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 8),
          sliver: const SliverToBoxAdapter(
            child: SectionHeading(
              title: 'Quick actions',
              subtitle: 'Open a CaringMate feature',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverToBoxAdapter(
            child: _QuickActions(columns: width >= 650 ? 4 : 2),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 8),
          sliver: const SliverToBoxAdapter(
            child: SectionHeading(
              title: 'Care connections',
              subtitle: 'Device and caregiver connection status',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
          sliver: const SliverToBoxAdapter(child: _ConnectionsCard()),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unreadCount = AppScope.of(context).unreadNotificationCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: brandBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CaringMate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: brandNavy,
                  ),
                ),
                Text(
                  'Your everyday care companion',
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1769AA), Color(0xFF174A78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.5,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Your health,\nall in one place.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Monitor, organise and stay connected.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 104,
            width: 92,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.columns});
  final int columns;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionItem>[
      _QuickActionItem(
        title: 'Emergency SOS',
        icon: Icons.emergency_rounded,
        color: const Color(0xFFE45B5B),
        onTap: () => _showEmergencyNotice(context),
      ),
      _QuickActionItem(
        title: 'Find hospitals',
        icon: Icons.local_hospital_rounded,
        color: const Color(0xFF347AC5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const HospitalSearchPage()),
        ),
      ),
      _QuickActionItem(
        title: 'Medication',
        icon: Icons.medication_rounded,
        color: const Color(0xFF279B76),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const MedicationPage()),
        ),
      ),
      _QuickActionItem(
        title: 'Hydration',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF2C9BC7),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const HydrationPage()),
        ),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: columns == 2 ? 1.9 : 1.25,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFE8EEF5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: item.color.withOpacity(0.12),
                    child: Icon(item.icon, color: item.color, size: 21),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: brandNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _ConnectionsCard extends StatelessWidget {
  const _ConnectionsCard();

  @override
  Widget build(BuildContext context) {
    return const SurfaceCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE5EFFB),
              child: Icon(Icons.watch_rounded, color: brandBlue),
            ),
            title: Text('FB Ninja Call Pro+'),
            subtitle: Text('Connected through DaFit when configured'),
            trailing: StatusPill(label: 'Not verified'),
          ),
          Divider(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE2F2E9),
              child: Icon(Icons.person_outline, color: Color(0xFF24875B)),
            ),
            title: Text('Caregiver'),
            subtitle: Text('No caregiver account linked yet'),
            trailing: StatusPill(label: 'Not linked'),
          ),
        ],
      ),
    );
  }
}

void _showEmergencyNotice(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 38,
      ),
      title: const Text('Emergency feature is not active'),
      content: const Text(
        'This prototype does not call emergency services, notify caregivers '
        'or share your location. A tested emergency workflow must be '
        'implemented before relying on this feature.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

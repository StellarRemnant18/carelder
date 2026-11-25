import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: [
        const PageHeader(
          title: 'Health',
          subtitle: 'Measurements and connected health sources',
        ),
        const DemoDataNotice(),
        const SizedBox(height: 18),
        const SectionHeading(
          title: 'Health measurements',
          subtitle: 'Sample values for layout preview only',
        ),
        const SizedBox(
          height: 134,
          child: Row(
            children: [
              Expanded(
                child: HealthMetricCard(
                  title: 'Heart rate',
                  value: '72',
                  unit: 'BPM',
                  icon: Icons.favorite_rounded,
                  color: Color(0xFFE85D75),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: HealthMetricCard(
                  title: 'SpO₂',
                  value: '98',
                  unit: '%',
                  icon: Icons.air_rounded,
                  color: Color(0xFF269B83),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(
          height: 134,
          child: Row(
            children: [
              Expanded(
                child: HealthMetricCard(
                  title: 'Blood pressure',
                  value: '120/80',
                  unit: 'mmHg',
                  icon: Icons.monitor_heart_rounded,
                  color: Color(0xFF477ED4),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: HealthMetricCard(
                  title: 'Steps today',
                  value: '5,421',
                  unit: 'steps',
                  icon: Icons.directions_walk_rounded,
                  color: Color(0xFFE49A36),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeading(
          title: 'Data connections',
          subtitle: 'The proposed synchronization chain',
        ),
        IntegrationTile(
          icon: Icons.watch_rounded,
          title: 'DaFit smartwatch',
          subtitle: 'FB Ninja Call Pro+ · source app',
          status: 'Not verified',
          onTap: () => showInfoDialog(
            context,
            title: 'DaFit connection',
            message:
                'Pair the watch in the official DaFit application first. '
                'CaringMate does not directly pair with this watch in this build.',
          ),
        ),
        const SizedBox(height: 9),
        IntegrationTile(
          icon: Icons.fitness_center_rounded,
          title: 'Google Fit',
          subtitle: 'Possible bridge from DaFit',
          status: 'Not verified',
          onTap: () => showInfoDialog(
            context,
            title: 'Google Fit sync',
            message:
                'Confirm that DaFit has actually written the required data '
                'into Google Fit. A successful account connection alone does '
                'not prove that every measurement is transferred.',
          ),
        ),
        const SizedBox(height: 9),
        IntegrationTile(
          icon: Icons.health_and_safety_rounded,
          title: 'Health Connect',
          subtitle: 'Android health-data access layer',
          status: 'Not connected',
          onTap: () => showInfoDialog(
            context,
            title: 'Health Connect',
            message:
                'The Android SDK, manifest declarations and data permissions '
                'must be added and tested before this screen can read records.',
          ),
        ),
        const SizedBox(height: 18),
        const EmptyState(
          icon: Icons.insights_outlined,
          title: 'Trends will appear here',
          message:
              'Verified historical records can later be displayed as charts. '
              'This build does not fabricate a health history.',
        ),
        const SizedBox(height: 14),
        const Text(
          'Health information in CaringMate is intended to support personal '
          'record keeping. It is not a diagnosis or a substitute for qualified '
          'medical advice.',
          style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';
import 'hydration_page.dart';
import 'medication_page.dart';

class CarePage extends StatelessWidget {
  const CarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: [
        const PageHeader(
          title: 'Care centre',
          subtitle: 'Everyday tools and care organisation',
        ),
        _CareFeatureCard(
          icon: Icons.medication_rounded,
          color: const Color(0xFF279B76),
          title: 'Medication reminders',
          description: 'Create a personal list of medication reminders and mark entries complete.',
          buttonLabel: 'Open medication manager',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const MedicationPage()),
          ),
        ),
        const SizedBox(height: 12),
        _CareFeatureCard(
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF2C9BC7),
          title: 'Hydration tracker',
          description: 'Record water intake manually. The displayed amount is a personal log, not a prescribed target.',
          buttonLabel: 'Open hydration tracker',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const HydrationPage()),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeading(
          title: 'Caregiver network',
          subtitle: 'Account linking is not configured yet',
        ),
        const EmptyState(
          icon: Icons.groups_outlined,
          title: 'No caregiver linked',
          message:
              'Caregiver invitations, role-based access and consent controls '
              'need a secure account and backend implementation.',
        ),
      ],
    );
  }
}

class _CareFeatureCard extends StatelessWidget {
  const _CareFeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF102A43),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

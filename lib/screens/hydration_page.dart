import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../widgets/app_widgets.dart';

class HydrationPage extends StatelessWidget {
  const HydrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    const displayReferenceMl = 2000;
    final progress = (app.waterIntakeMl / displayReferenceMl)
        .clamp(0.0, 1.0)
        .toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Hydration tracker')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DemoDataNotice(),
          const SizedBox(height: 18),
          SurfaceCard(
            child: Column(
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF2C9BC7),
                  size: 48,
                ),
                const SizedBox(height: 10),
                Text(
                  '${app.waterIntakeMl} ml',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Color(0xFF102A43),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Water manually logged in this session',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE7F0F8),
                    color: const Color(0xFF2C9BC7),
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Progress uses a 2,000 ml example display reference only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeading(
            title: 'Add water',
            subtitle: 'Select the amount you want to record',
          ),
          Row(
            children: [
              Expanded(child: _WaterButton(amount: 150)),
              const SizedBox(width: 9),
              Expanded(child: _WaterButton(amount: 250)),
              const SizedBox(width: 9),
              Expanded(child: _WaterButton(amount: 500)),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: app.waterIntakeMl == 0
                ? null
                : () => _confirmReset(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset session counter'),
          ),
          const SizedBox(height: 14),
          const Text(
            'Fluid needs vary. This tracker is a simple personal log and does '
            'not prescribe a daily intake target. Follow advice from a '
            'qualified healthcare professional where appropriate.',
            style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset counter?'),
        content: const Text('Clear the water entries from this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      AppScope.of(context).resetWater();
    }
  }
}

class _WaterButton extends StatelessWidget {
  const _WaterButton({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => AppScope.of(context).addWater(amount),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text('+ $amount ml'),
    );
  }
}

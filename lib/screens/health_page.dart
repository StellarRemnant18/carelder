
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/app_widgets.dart';
import '../services/health_connect_service.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final HealthConnectService _healthConnect = HealthConnectService();

  String _healthConnectStatus = 'Not connected';
  bool _healthConnectConnected = false;
  bool _isCheckingHealthConnect = false;

  Future<void> _connectHealthConnect() async {
    if (_isCheckingHealthConnect) return;

    setState(() {
      _isCheckingHealthConnect = true;
      _healthConnectStatus = 'Checking...';
    });

    try {
      final availability = await _healthConnect.checkAvailability();

      if (!mounted) return;

      if (availability != 'available') {
        setState(() {
          _healthConnectConnected = false;
          _healthConnectStatus =
              availability == 'update_required'
                  ? 'Update required'
                  : 'Unavailable';
        });
        return;
      }

      final permissions =
          await _healthConnect.requestPermissions();

      if (!mounted) return;

      final stepsGranted = permissions['steps'] ?? false;
      final heartRateGranted = permissions['heartRate'] ?? false;

      setState(() {
        _healthConnectConnected =
            stepsGranted && heartRateGranted;

        if (_healthConnectConnected) {
          _healthConnectStatus = 'Access allowed';
        } else if (stepsGranted || heartRateGranted) {
          _healthConnectStatus = 'Partially allowed';
        } else {
          _healthConnectStatus = 'Permission denied';
        }
      });
    } on PlatformException catch (e) {
      if (!mounted) return;

      setState(() {
        _healthConnectConnected = false;
        _healthConnectStatus = 'Connection error';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Health Connect error'),
        ),
      );
    } on MissingPluginException {
      if (!mounted) return;

      setState(() {
        _healthConnectConnected = false;
        _healthConnectStatus = 'Restart required';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _healthConnectConnected = false;
        _healthConnectStatus = 'Connection error';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingHealthConnect = false;
        });
      }
    }
  }

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
          subtitle: _isCheckingHealthConnect
              ? 'Checking connection...'
              : 'Tap to check availability and grant permissions',
          status: _healthConnectStatus,
          connected: _healthConnectConnected,
          onTap: _connectHealthConnect,
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
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

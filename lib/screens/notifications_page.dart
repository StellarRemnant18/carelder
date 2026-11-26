import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../services/firebase_messaging_service.dart';
import '../widgets/app_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.permissionService});

  final NotificationPermissionService? permissionService;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationPermissionService _permissionService =
      widget.permissionService ?? FirebaseMessagingService();

  AuthorizationStatus? _permissionStatus;
  String? _permissionError;
  bool _isLoadingPermission = true;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    setState(() {
      _isLoadingPermission = true;
      _permissionError = null;
    });
    try {
      final status = await _permissionService.getPermissionStatus();
      if (!mounted) return;
      setState(() => _permissionStatus = status);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionError =
            'Notification permission status is unavailable on this device.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingPermission = false);
      }
    }
  }

  Future<void> _requestPermission() async {
    if (_isRequestingPermission) return;
    setState(() {
      _isRequestingPermission = true;
      _permissionError = null;
    });
    try {
      final status = await _permissionService.requestPermission();
      if (!mounted) return;
      setState(() => _permissionStatus = status);
      final message = _isPermissionGranted(status)
          ? 'Notification permission enabled.'
          : 'Notification permission was not granted.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionError =
            'Could not request notification permission. Check device '
            'settings and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isRequestingPermission = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final notifications = app.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') app.markAllNotificationsRead();
                if (value == 'clear') app.clearNotifications();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'read', child: Text('Mark all as read')),
                PopupMenuItem(value: 'clear', child: Text('Clear all')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildPermissionCard(),
          const SizedBox(height: 16),
          if (notifications.isEmpty)
            const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'You are all caught up',
              message:
                  'Messages received while CaringMate is open appear here. '
                  'Background message registration and notification actions '
                  'are not configured in this build.',
            )
          else
            for (final item in notifications)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: SurfaceCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: item.isRead
                          ? const Color(0xFFEAF0F5)
                          : const Color(0xFFDDEEFF),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: item.isRead ? Colors.blueGrey : Colors.blue,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isRead
                            ? FontWeight.w600
                            : FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      '${item.body}\n${_formatDate(item.receivedAt)}',
                    ),
                    isThreeLine: true,
                    trailing: item.isRead
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.circle, size: 9, color: Colors.blue),
                    onTap: () => app.markNotificationRead(item.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard() {
    final granted =
        _permissionStatus != null && _isPermissionGranted(_permissionStatus!);
    final statusLabel = _isLoadingPermission
        ? 'Checking...'
        : _permissionError != null
        ? 'Unavailable'
        : granted
        ? 'Allowed'
        : _permissionStatus == AuthorizationStatus.denied
        ? 'Blocked'
        : 'Not requested';

    final statusMessage = _isLoadingPermission
        ? 'Checking the notification permission on this device.'
        : _permissionError ??
              (granted
                  ? 'Permission is allowed. Messages received while the app '
                        'is open appear in this list; background registration '
                        'and notification actions still need setup.'
                  : _permissionStatus == AuthorizationStatus.denied
                  ? 'Permission is off. You may need to enable notifications '
                        'for CaringMate in device settings.'
                  : 'Allow notifications to receive alerts from CaringMate.');

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Push notifications',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              StatusPill(label: statusLabel, positive: granted),
            ],
          ),
          const SizedBox(height: 8),
          Text(statusMessage),
          if (_permissionError != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isLoadingPermission ? null : _loadPermissionStatus,
              child: const Text('Check again'),
            ),
          ] else if (!granted) ...[
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: _isLoadingPermission || _isRequestingPermission
                  ? null
                  : _requestPermission,
              icon: _isRequestingPermission
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications),
              label: Text(
                _isRequestingPermission
                    ? 'Requesting permission...'
                    : 'Enable notifications',
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isPermissionGranted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} · $hour:$minute';
  }
}

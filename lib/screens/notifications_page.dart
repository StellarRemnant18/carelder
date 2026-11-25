import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../widgets/app_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
      body: notifications.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(18),
              child: EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'You are all caught up',
                message:
                    'Push notifications received while the app is open will '
                    'appear here. Background and terminated-app handling '
                    'still needs platform configuration.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return SurfaceCard(
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
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} · $hour:$minute';
  }
}

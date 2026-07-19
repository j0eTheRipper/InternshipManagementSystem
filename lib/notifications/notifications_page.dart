import 'package:flutter/material.dart';
import 'package:internship_management_system/api/notification.dart';
import 'package:internship_management_system/notifications/notification_service.dart';
import 'package:internship_management_system/models/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationData>? _notifications;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _notifications = await getNotifications();
    } catch (_) {
      _notifications = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markAsRead(NotificationData notification) async {
    try {
      await markAsRead(notification.notificationId);
      if (mounted) {
        setState(() {
          final idx = _notifications?.indexWhere(
            (n) => n.notificationId == notification.notificationId,
          );
          if (idx != null && idx >= 0) {
            _notifications![idx].isRead = true;
          }
        });
      }
      NotificationService.instance.fetchUnread();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_notifications == null || _notifications!.isEmpty)
              _buildEmpty()
            else
              ..._notifications!.map(_buildNotificationCard),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 48, color: Color(0xFFBDBDBD)),
            SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationData notification) {
    final isUnread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isUnread ? () => _markAsRead(notification) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF0F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFF2196F3).withValues(alpha: 0.3)
                  : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _iconBg(notification.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _icon(notification.type),
                    size: 20,
                    color: _iconFg(notification.type),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (notification.createdAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          notification.createdAt!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'resume_upload':
        return Icons.upload_file;
      case 'resume_approved':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconBg(String type) {
    switch (type) {
      case 'resume_upload':
        return const Color(0xFFFFF3E0);
      case 'resume_approved':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _iconFg(String type) {
    switch (type) {
      case 'resume_upload':
        return const Color(0xFFE65100);
      case 'resume_approved':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF616161);
    }
  }
}

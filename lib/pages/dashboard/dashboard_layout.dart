import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/notifications/notification_service.dart';
import 'package:internship_management_system/notifications/chat_notification_service.dart';
import 'package:internship_management_system/pages/dashboard/sidebar.dart';
import 'package:internship_management_system/Widgets/mobile_bottom_nav.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _unreadCount = 0;
  int _chatUnreadCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _unreadCount = NotificationService.instance.unreadCount;
    _chatUnreadCount = ChatNotificationService.instance.unreadCount;
    NotificationService.instance.addListener(_onUnreadChanged);
    ChatNotificationService.instance.addListener(_onUnreadChanged);
    NotificationService.instance.fetchUnread();
    ChatNotificationService.instance.fetchUnread();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        NotificationService.instance.fetchUnread();
        ChatNotificationService.instance.fetchUnread();
      },
    );
  }

  void _onUnreadChanged() {
    if (mounted) {
      setState(() {
        _unreadCount = NotificationService.instance.unreadCount;
        _chatUnreadCount = ChatNotificationService.instance.unreadCount;
      });
    }
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onUnreadChanged);
    ChatNotificationService.instance.removeListener(_onUnreadChanged);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (kIsWeb) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 260, child: Sidebar()),
          const VerticalDivider(width: 1, color: Color(0xFFE0E0E0)),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1A1A1A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Internship Manager',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1A1A1A)),
                onPressed: () => context.go('/chat'),
              ),
              if (_chatUnreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _chatUnreadCount > 99 ? '99+' : '$_chatUnreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded, color: Color(0xFF1A1A1A)),
                onPressed: () => context.go('/notifications'),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        backgroundColor: const Color(0xFFFAFAFA),
        child: const Sidebar(isInDrawer: true),
      ),
      body: widget.child,
      bottomNavigationBar: const MobileBottomNav(),
    );
  }
}

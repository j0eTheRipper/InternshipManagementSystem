import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/notifications/chat_notification_service.dart';

class MobileBottomNav extends StatefulWidget {
  const MobileBottomNav({super.key});

  @override
  State<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends State<MobileBottomNav> {
  int _chatUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _chatUnreadCount = ChatNotificationService.instance.unreadCount;
    ChatNotificationService.instance.addListener(_onUnreadChanged);
    ChatNotificationService.instance.fetchUnread();
  }

  void _onUnreadChanged() {
    if (mounted) {
      setState(() {
        _chatUnreadCount = ChatNotificationService.instance.unreadCount;
      });
    }
  }

  @override
  void dispose() {
    ChatNotificationService.instance.removeListener(_onUnreadChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInterning = AuthState.currentStudent?.progress == 'accepted';
    final currentRoute = GoRouterState.of(context).uri.toString();

    final destinations = isInterning ? _interningDestinations : _preInternshipDestinations;

    final currentIndex = destinations.indexWhere(
      (d) => currentRoute == d.route || currentRoute.startsWith(d.route),
    );

    return NavigationBar(
      selectedIndex: currentIndex >= 0 ? currentIndex : 0,
      onDestinationSelected: (index) => context.go(destinations[index].route),
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF030213).withValues(alpha: 0.08),
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: destinations
          .map(
            (d) => NavigationDestination(
              icon: d.label == 'Chat' && _chatUnreadCount > 0
                  ? _buildBadge(icon: Icon(d.icon, size: 22), count: _chatUnreadCount)
                  : Icon(d.icon, size: 22),
              selectedIcon: d.label == 'Chat' && _chatUnreadCount > 0
                  ? _buildBadge(icon: Icon(d.icon, size: 22, color: const Color(0xFF030213)), count: _chatUnreadCount)
                  : Icon(d.icon, size: 22, color: const Color(0xFF030213)),
              label: d.label,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBadge({required Widget icon, required int count}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;
  final String route;

  const _NavDestination({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const _preInternshipDestinations = [
  _NavDestination(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/dashboard'),
  _NavDestination(icon: Icons.business_rounded, label: 'Opportunities', route: '/opportunities'),
  _NavDestination(icon: Icons.chat_bubble_outline_rounded, label: 'Chat', route: '/chat'),
  _NavDestination(icon: Icons.assignment_rounded, label: 'Applications', route: '/my-applications'),
  _NavDestination(icon: Icons.person_rounded, label: 'Profile', route: '/profile'),
];

const _interningDestinations = [
  _NavDestination(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/dashboard'),
  _NavDestination(icon: Icons.event_available_outlined, label: 'Attendance', route: '/attendance'),
  _NavDestination(icon: Icons.edit_note_rounded, label: 'Work Logs', route: '/work-logs'),
  _NavDestination(icon: Icons.chat_bubble_outline_rounded, label: 'Chat', route: '/chat'),
  _NavDestination(icon: Icons.person_rounded, label: 'Profile', route: '/profile'),
];

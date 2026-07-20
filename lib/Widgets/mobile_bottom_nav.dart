import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

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
              icon: Icon(d.icon, size: 22),
              selectedIcon: Icon(d.icon, size: 22, color: const Color(0xFF030213)),
              label: d.label,
            ),
          )
          .toList(),
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

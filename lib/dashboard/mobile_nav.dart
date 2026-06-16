import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileNav extends StatelessWidget {
  const MobileNav({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MobileNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              route: '/dashboard',
              isActive: currentRoute == '/dashboard',
            ),
            _MobileNavItem(
              icon: Icons.business_rounded,
              label: 'Companies',
              route: '/companies',
              isActive: currentRoute == '/companies',
            ),
            _MobileNavItem(
              icon: Icons.chat_rounded,
              label: 'Chat',
              route: '/chat',
              isActive: currentRoute == '/chat',
            ),
            _MobileNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              route: '/profile',
              isActive: currentRoute == '/profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF030213)
                  : const Color(0xFF717182),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF030213)
                    : const Color(0xFF717182),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

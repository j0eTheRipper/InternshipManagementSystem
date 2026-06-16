import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/dashboard/sidebar.dart';
import 'package:internship_management_system/dashboard/mobile_nav.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AuthState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        return Scaffold(
          backgroundColor: isDesktop ? null : const Color(0xFFF8F9FA),
          appBar: isDesktop
              ? null
              : AppBar(
                  title: Text(_pageTitle(context)),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                ),
          body: Row(
            children: [
              if (isDesktop) ...[
                const SizedBox(
                  width: 260,
                  child: Sidebar(),
                ),
                const VerticalDivider(
                  width: 1,
                  color: Color(0xFFE0E0E0),
                ),
              ],
              Expanded(
                child: child,
              ),
            ],
          ),
          bottomNavigationBar: isDesktop ? null : const MobileNav(),
        );
      },
    );
  }

  String _pageTitle(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/companies':
        return 'Companies';
      case '/chat':
        return 'Chat';
      case '/profile':
        return 'Profile';
      default:
        return '';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/pages/dashboard/sidebar.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AuthState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 260, child: Sidebar()),
          const VerticalDivider(width: 1, color: Color(0xFFE0E0E0)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

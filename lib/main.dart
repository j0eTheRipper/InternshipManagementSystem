import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/dashboard/dashboard_layout.dart';
import 'package:internship_management_system/dashboard/pages/chat_page.dart';
import 'package:internship_management_system/dashboard/pages/dashboard_page.dart';
import 'package:internship_management_system/dashboard/pages/headhunter_postings_page.dart';
import 'package:internship_management_system/dashboard/pages/headhunter_register_page.dart';
import 'package:internship_management_system/dashboard/pages/my_applications_page.dart';
import 'package:internship_management_system/dashboard/pages/notifications_page.dart';
import 'package:internship_management_system/dashboard/pages/opportunities_page.dart';
import 'package:internship_management_system/dashboard/pages/opportunity_detail_page.dart';
import 'package:internship_management_system/dashboard/pages/profile_page.dart';
import 'package:internship_management_system/dashboard/pages/resume_page.dart';
import 'package:internship_management_system/login_screen/login_screen.dart';

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = AuthState.isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';
    final isRegisterRoute = state.matchedLocation == '/register/headhunter';

    if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
      return '/login';
    }
    if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/register/headhunter',
      builder: (context, state) => const HeadhunterRegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => DashboardLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/opportunities',
          builder: (context, state) => const OpportunitiesPage(),
        ),
        GoRoute(
          path: '/opportunities/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return OpportunityDetailPage(opportunityId: id);
          },
        ),
        GoRoute(
          path: '/my-applications',
          builder: (context, state) => const MyApplicationsPage(),
        ),
        GoRoute(
          path: '/headhunter/postings',
          builder: (context, state) => const HeadhunterPostingsPage(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatPage(),
        ),
        GoRoute(
          path: '/resume',
          builder: (context, state) => const ResumePage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthState.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Internship Manager',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/notifications/notification_service.dart';
import 'package:internship_management_system/Widgets/nav_item.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _unreadCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _unreadCount = NotificationService.instance.unreadCount;
    NotificationService.instance.addListener(_onUnreadChanged);
    NotificationService.instance.fetchUnread();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => NotificationService.instance.fetchUnread(),
    );
  }

  void _onUnreadChanged() {
    if (mounted) {
      setState(() => _unreadCount = NotificationService.instance.unreadCount);
    }
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onUnreadChanged);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthState.currentRole;
    final isStudent = role == 'student';
    final isHeadhunter = role == 'headhunter';
    final isInterning = AuthState.currentStudent?.progress == 'accepted';
    final isPendingDocs = AuthState.currentStudent?.progress == 'pending_documents';
    final isAdmin = role == 'admin';
    final isCompanySupervisor = role == 'companySupervisor';
    final userName = AuthState.currentUser?.fullname ?? '';

    String roleLabel;
    if (isStudent) {
      roleLabel = 'Student';
    } else if (isHeadhunter) {
      roleLabel = 'Headhunter';
    } else if (isCompanySupervisor) {
      roleLabel = 'Company Supervisor';
    } else {
      roleLabel = 'University Mentor';
    }

    return Container(
      width: 260,
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF030213),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF717182),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 9),
                if (!isAdmin)
                  NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: '/dashboard',
                  ),
                if (isStudent && !isInterning && !isPendingDocs) ...[
                  NavItem(
                    icon: Icons.business_rounded,
                    label: 'Opportunities',
                    route: '/opportunities',
                  ),
                ],
                if (isStudent && isInterning) ...[
                  NavItem(
                    icon: Icons.event_available_outlined,
                    label: 'Attendance',
                    route: '/attendance',
                  ),
                  NavItem(
                    icon: Icons.edit_note_rounded,
                    label: 'Work Logs',
                    route: '/work-logs',
                  ),
                ],
                if (isStudent && !isInterning && !isPendingDocs) ...[
                  NavItem(
                    icon: Icons.assignment_rounded,
                    label: 'My Applications',
                    route: '/my-applications',
                  ),
                  NavItem(
                    icon: Icons.description_outlined,
                    label: 'Resume',
                    route: '/resume',
                  ),
                ],
                if (isHeadhunter) ...[
                  NavItem(
                    icon: Icons.post_add_rounded,
                    label: 'My Postings',
                    route: '/headhunter/postings',
                  ),
                ],
                if (isAdmin) ...[
                  NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: '/admin/dashboard',
                  ),
                  NavItem(
                    icon: Icons.people_outline,
                    label: 'Students',
                    route: '/admin/students',
                  ),
                  NavItem(
                    icon: Icons.school_outlined,
                    label: 'Mentors',
                    route: '/admin/mentors',
                  ),
                  NavItem(
                    icon: Icons.business_center_outlined,
                    label: 'Company Supervisors',
                    route: '/admin/company-supervisors',
                  ),
                  NavItem(
                    icon: Icons.event_available_outlined,
                    label: 'Attendance',
                    route: '/admin/attendance',
                  ),
                ],
                if (isCompanySupervisor) ...[
                  NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: '/company-supervisor/dashboard',
                  ),
                  NavItem(
                    icon: Icons.people_outline,
                    label: 'My Students',
                    route: '/company-supervisor/students',
                  ),
                ],
                if (!isStudent && !isHeadhunter && !isAdmin && !isCompanySupervisor) ...[
                  NavItem(
                    icon: Icons.people_outline,
                    label: 'All Students',
                    route: '/mentor/all-students',
                  ),
                  NavItem(
                    icon: Icons.folder_outlined,
                    label: 'Student Documents',
                    route: '/mentor/student-documents',
                  ),
                  NavItem(
                    icon: Icons.pending_actions_outlined,
                    label: 'Pending Documents',
                    route: '/mentor/pending-documents',
                  ),
                ],
                _NotificationNavItem(unreadCount: _unreadCount),
                NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  route: '/profile',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthState.logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF717182),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationNavItem extends StatelessWidget {
  final int unreadCount;

  const _NotificationNavItem({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isActive = currentRoute == '/notifications';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go('/notifications'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF030213) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_rounded,
                  size: 20,
                  color: isActive ? Colors.white : const Color(0xFF717182),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFFE53935)
                            : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

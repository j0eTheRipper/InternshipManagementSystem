import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/services/push_notification_service.dart';
import 'package:internship_management_system/pages/dashboard/dashboard_layout.dart';
import 'package:internship_management_system/pages/chat/chat_page.dart';
import 'package:internship_management_system/pages/dashboard/pages/dashboard_page.dart';
import 'package:internship_management_system/pages/headhunter/headhunter_postings_page.dart';
import 'package:internship_management_system/pages/headhunter/headhunter_register_page.dart';
import 'package:internship_management_system/pages/applications/my_applications_page.dart';
import 'package:internship_management_system/pages/applications/external_application_page.dart';
import 'package:internship_management_system/pages/applications/external_application_detail_page.dart';
import 'package:internship_management_system/notifications/notifications_page.dart';
import 'package:internship_management_system/pages/opportunities/opportunities_page.dart';
import 'package:internship_management_system/pages/opportunities/opportunity_detail_page.dart';
import 'package:internship_management_system/pages/offer_letter/mentor_offer_letters_page.dart';
import 'package:internship_management_system/pages/profile/profile_page.dart';
import 'package:internship_management_system/pages/student_documents/all_students_page.dart';
import 'package:internship_management_system/pages/student_documents/student_documents_page.dart';
import 'package:internship_management_system/pages/student_documents/student_detail_page.dart';
import 'package:internship_management_system/pages/resume/resume_page.dart';
import 'package:internship_management_system/pages/login_screen/login_screen.dart';
import 'package:internship_management_system/pages/attendance/attendance_page.dart';
import 'package:internship_management_system/pages/work_logs/work_logs_page.dart';
import 'package:internship_management_system/pages/admin/admin_dashboard_page.dart';
import 'package:internship_management_system/pages/admin/admin_students_page.dart';
import 'package:internship_management_system/pages/admin/admin_add_student_form.dart';
import 'package:internship_management_system/pages/admin/admin_mentors_page.dart';
import 'package:internship_management_system/pages/admin/admin_attendance_page.dart';
import 'package:internship_management_system/pages/admin/admin_company_supervisors_page.dart';
import 'package:internship_management_system/pages/company_supervisor/company_supervisor_pages.dart';
import 'package:internship_management_system/pages/mentor/pending_documents_verification_page.dart';

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

    final location = state.matchedLocation;
    final isInterning =
        AuthState.isStudent && AuthState.currentStudent?.progress == 'accepted';
    if (isInterning &&
        (location == '/opportunities' ||
            location.startsWith('/opportunities/'))) {
      return '/dashboard';
    }

    final isPendingDocs =
        AuthState.isStudent &&
        AuthState.currentStudent?.progress == 'pending_documents';
    if (isPendingDocs &&
        location != '/dashboard' &&
        location != '/notifications' &&
        location != '/profile') {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const Login()),
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
          path: '/my-applications/external/new',
          builder: (context, state) => const ExternalApplicationPage(),
        ),
        GoRoute(
          path: '/my-applications/external/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ExternalApplicationDetailPage(applicationId: id);
          },
        ),
        GoRoute(
          path: '/headhunter/postings',
          builder: (context, state) => const HeadhunterPostingsPage(),
        ),
        GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
        GoRoute(
          path: '/resume',
          builder: (context, state) => const ResumePage(),
        ),
        GoRoute(
          path: '/mentor/offer-letters',
          builder: (context, state) => const MentorOfferLettersPage(),
        ),
        GoRoute(
          path: '/mentor/all-students',
          builder: (context, state) => const AllStudentsPage(),
        ),
        GoRoute(
          path: '/mentor/student-documents',
          builder: (context, state) => const StudentDocumentsPage(),
        ),
        GoRoute(
          path: '/mentor/student-detail/:studentId',
          builder: (context, state) =>
              StudentDetailPage(studentId: state.pathParameters['studentId']!),
        ),
        GoRoute(
          path: '/mentor/pending-documents',
          builder: (context, state) => const MentorPendingDocumentsPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const AttendancePage(),
        ),
        GoRoute(
          path: '/work-logs',
          builder: (context, state) => const WorkLogsPage(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/students',
          builder: (context, state) => const AdminStudentsPage(),
        ),
        GoRoute(
          path: '/admin/students/new',
          builder: (context, state) => const AdminAddStudentForm(),
        ),
        GoRoute(
          path: '/admin/mentors',
          builder: (context, state) => const AdminMentorsPage(),
        ),
        GoRoute(
          path: '/admin/attendance',
          builder: (context, state) => const AdminAttendancePage(),
        ),
        GoRoute(
          path: '/admin/company-supervisors',
          builder: (context, state) => const AdminCompanySupervisorsPage(),
        ),
        GoRoute(
          path: '/company-supervisor/dashboard',
          builder: (context, state) => const CompanySupervisorDashboard(),
        ),
        GoRoute(
          path: '/company-supervisor/students',
          builder: (context, state) => const CompanySupervisorStudentsPage(),
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  await dotenv.load();
  await AuthState.init();
  if (!kIsWeb) {
    await PushNotificationService.init();
  }
  AuthState.router = _router;
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

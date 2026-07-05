import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/opportunity.dart';
import 'package:internship_management_system/models/student.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthState.isStudent) {
      return const _StudentDashboard();
    } else if (AuthState.isHeadhunter) {
      return const _HeadhunterDashboard();
    }
    return const _MentorDashboard();
  }
}

class _StudentDashboard extends StatefulWidget {
  const _StudentDashboard();

  @override
  State<_StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<_StudentDashboard> {
  Student? _student;
  List<Opportunity> _opportunities = [];
  int _applicationCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId = AuthState.currentUser?.userId;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final results = await Future.wait([
        getStudent(userId.toString()),
        getOpportunities(),
        getMyApplications(),
      ]);
      if (mounted) {
        setState(() {
          _student = results[0] as Student;
          _opportunities = results[1] as List<Opportunity>;
          _applicationCount = (results[2] as List).length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _student = AuthState.currentStudent;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = AuthState.currentUser;
    final student = _student;
    final recent = _opportunities.take(5).toList();

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.fullname ?? 'Student'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student != null
                  ? '${student.fieldOfStudy} · Year ${student.yearOfStudy}'
                  : 'Manage your internship journey',
              style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),
            if (student != null) _ProgressCard(student: student),
            if (student != null) const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.work_outline,
                    label: 'Applications',
                    value: '$_applicationCount',
                    color: const Color(0xFF030213),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Active',
                    value: '${_opportunities.length}',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.school_outlined,
                    label: 'Mentor',
                    value: student?.universityMentor.fullname ?? 'N/A',
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Opportunities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/opportunities'),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No opportunities available yet.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                  ),
                ),
              )
            else
              ...recent.map(
                (opp) => _DashboardOpportunityCard(
                  company: opp.company ?? 'Unknown',
                  role: opp.jobRole,
                  title: opp.title,
                  location: opp.location,
                  status: opp.status,
                  onTap: () =>
                      context.go('/opportunities/${opp.opportunityId}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardOpportunityCard extends StatelessWidget {
  final String company;
  final String role;
  final String title;
  final String location;
  final String status;
  final VoidCallback onTap;

  const _DashboardOpportunityCard({
    required this.company,
    required this.role,
    required this.title,
    required this.location,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    company.isNotEmpty ? company[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF030213),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$company · $role',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF717182),
                      ),
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'remote'
                      ? const Color(0xFFE8F5E9)
                      : status == 'hybrid'
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: status == 'remote'
                        ? const Color(0xFF2E7D32)
                        : status == 'hybrid'
                        ? const Color(0xFFE65100)
                        : const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentorDashboard extends StatefulWidget {
  const _MentorDashboard();

  @override
  State<_MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<_MentorDashboard> {
  List<Student> _students = [];
  Map<String, String?> _companyCache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final students = await getMentorStudents();
      final accepted = students.where((s) => s.progress == 'accepted');
      final companies = <String, String?>{};
      for (final s in accepted) {
        try {
          companies[s.studentId] = await getAcceptedCompany(s.studentId);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _students = students;
          _companyCache = companies;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _statusFromProgress(String progress) {
    switch (progress) {
      case 'resume':
      case 'offer_letter':
        return 'Pending Review';
      default:
        return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser;

    final pendingCount =
        _students.where((s) => _statusFromProgress(s.progress) == 'Pending Review').length;
    final activeCount = _students.length - pendingCount;

    if (_loading) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.fullname ?? 'Mentor'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'University Mentor Dashboard',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_outline,
                    label: 'Students',
                    value: '${_students.length}',
                    color: const Color(0xFF030213),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.assignment_outlined,
                    label: 'Pending Reviews',
                    value: '$pendingCount',
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Active',
                    value: '$activeCount',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Students',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/mentor/student-documents'),
                  child: const Text('Review documents'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_students.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No students assigned yet.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                  ),
                ),
              )
            else
              ..._students.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentCard(
                    name: student.user.fullname,
                    field: student.fieldOfStudy,
                    year: student.yearOfStudy,
                    status: _statusFromProgress(student.progress),
                    company: _companyCache[student.studentId],
                    onTap: () => context.go(
                      '/mentor/student-detail/${student.studentId}',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Student student;

  const _ProgressCard({required this.student});

  @override
  Widget build(BuildContext context) {
    const stages = ['Resume', 'Application', 'Offer Letter'];
    const progressValues = ['resume', 'application', 'offer_letter'];

    final currentIndex = progressValues.indexOf(student.progress);
    if (currentIndex < 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(stages.length * 2 - 1, (index) {
              if (index.isOdd) {
                final leftStageIndex = index ~/ 2;
                final lineCompleted = leftStageIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: lineCompleted
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE0E0E0),
                  ),
                );
              }
              final stageIndex = index ~/ 2;
              return _StageIndicator(
                number: stageIndex + 1,
                label: stages[stageIndex],
                isActive: stageIndex == currentIndex,
                isCompleted: stageIndex < currentIndex,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StageIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StageIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isCompleted
        ? const Color(0xFF2E7D32)
        : isActive
        ? const Color(0xFF030213)
        : const Color(0xFFE0E0E0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? const Color(0xFF1A1A1A)
                : isCompleted
                ? const Color(0xFF2E7D32)
                : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF717182)),
          ),
        ],
      ),
    );
  }
}

class _HeadhunterDashboard extends StatelessWidget {
  const _HeadhunterDashboard();

  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser;
    final headhunter = AuthState.currentHeadhunter;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.fullname ?? 'Headhunter'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${headhunter?.company ?? 'Your Company'} · Headhunter Dashboard',
              style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.post_add_rounded,
                    label: 'Active Postings',
                    value: '-',
                    color: const Color(0xFF030213),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_outlined,
                    label: 'Total Applicants',
                    value: '-',
                    color: const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Accepted',
                    value: '-',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String field;
  final int year;
  final String status;
  final String? company;
  final VoidCallback? onTap;

  const _StudentCard({
    required this.name,
    required this.field,
    required this.year,
    required this.status,
    this.company,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending Review';
    final showCompany = company != null && status == 'Active';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF5F5F5),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF030213),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showCompany
                          ? '$field · Year $year · Accepted at $company'
                          : '$field · Year $year',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717182),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPending
                        ? const Color(0xFFE65100)
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

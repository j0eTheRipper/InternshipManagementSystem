import 'package:flutter/material.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/student.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthState.isStudent
        ? const _StudentDashboard()
        : const _MentorDashboard();
  }
}

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard();

  @override
  Widget build(BuildContext context) {
    final userId = AuthState.currentUser?.userId;
    if (userId == null) {
      return _buildBody(student: null);
    }

    return FutureBuilder<Student>(
      future: getStudent(userId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFFF8F9FA),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final student = snapshot.data ?? AuthState.currentStudent;
        return _buildBody(student: student);
      },
    );
  }

  Widget _buildBody({Student? student}) {
    final user = AuthState.currentUser;

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
                    value: '3',
                    color: const Color(0xFF030213),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Active',
                    value: '1',
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
            const Text(
              'Recent Opportunities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            _OpportunityCard(
              company: 'Tech Corp',
              role: 'Software Engineering Intern',
              location: 'Remote',
              match: '92% match',
            ),
            const SizedBox(height: 12),
            _OpportunityCard(
              company: 'DataFlow Inc',
              role: 'Data Science Intern',
              location: 'New York, NY',
              match: '85% match',
            ),
            const SizedBox(height: 12),
            _OpportunityCard(
              company: 'DesignLab',
              role: 'UI/UX Design Intern',
              location: 'San Francisco, CA',
              match: '78% match',
            ),
          ],
        ),
      ),
    );
  }
}

class _MentorDashboard extends StatelessWidget {
  const _MentorDashboard();

  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser;

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
                    value: '5',
                    color: const Color(0xFF030213),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.assignment_outlined,
                    label: 'Pending Reviews',
                    value: '3',
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_note_outlined,
                    label: 'This Month',
                    value: '12',
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Students Under Supervision',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            _StudentCard(
              name: 'Alice Johnson',
              field: 'Computer Science',
              year: 3,
              status: 'Pending Review',
            ),
            const SizedBox(height: 12),
            _StudentCard(
              name: 'Bob Smith',
              field: 'Software Engineering',
              year: 2,
              status: 'Active',
            ),
            const SizedBox(height: 12),
            _StudentCard(
              name: 'Carol Davis',
              field: 'Data Science',
              year: 3,
              status: 'Active',
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
    const progressValues = ['resume', 'appliation', 'offer_letter'];

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

class _OpportunityCard extends StatelessWidget {
  final String company;
  final String role;
  final String location;
  final String match;

  const _OpportunityCard({
    required this.company,
    required this.role,
    required this.location,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                company[0],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF030213),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              match,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String field;
  final int year;
  final String status;

  const _StudentCard({
    required this.name,
    required this.field,
    required this.year,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending Review';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  '$field · Year $year',
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/models/student.dart';

class AllStudentsPage extends StatefulWidget {
  const AllStudentsPage({super.key});

  @override
  State<AllStudentsPage> createState() => _AllStudentsPageState();
}

class _AllStudentsPageState extends State<AllStudentsPage> {
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
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusFromProgress(String progress) {
    switch (progress) {
      case 'none':
        return 'No Resume';
      case 'resume':
        return 'Resume';
      case 'application':
        return 'Application';
      case 'offer_letter':
        return 'Offer Letter';
      case 'pending_documents':
        return 'Pending Documents';
      case 'accepted':
        return 'Accepted';
      default:
        return progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Students',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'View all students under your supervision',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_students.isEmpty)
              _buildEmpty()
            else
              ..._students.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentCard(
                    name: student.user.fullname,
                    field: student.fieldOfStudy,
                    year: student.yearOfStudy,
                    status: _statusFromProgress(student.progress),
                    progress: student.progress,
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

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: const Center(
        child: Text(
          'No students assigned yet.',
          style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
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
  final String progress;
  final String? company;
  final VoidCallback? onTap;

  const _StudentCard({
    required this.name,
    required this.field,
    required this.year,
    required this.status,
    required this.progress,
    this.company,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = progress == 'resume' || progress == 'offer_letter' || progress == 'pending_documents';
    final showCompany = company != null && progress == 'accepted';

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

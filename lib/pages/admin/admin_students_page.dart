import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/admin.dart';
import 'package:internship_management_system/models/company_supervisor.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/models/user.dart';

class AdminStudentsPage extends StatefulWidget {
  const AdminStudentsPage({super.key});

  @override
  State<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends State<AdminStudentsPage> {
  List<Student> _students = [];
  List<User> _mentors = [];
  List<CompanySupervisor> _companySupervisors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([getAllStudents(), getAllMentors(), getAllCompanySupervisors()]);
      if (mounted) {
        setState(() {
          _students = results[0] as List<Student>;
          _mentors = results[1] as List<User>;
          _companySupervisors = results[2] as List<CompanySupervisor>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Color _progressColor(String progress) {
    switch (progress) {
      case 'none':
        return const Color(0xFF9E9E9E);
      case 'resume':
        return const Color(0xFF1565C0);
      case 'application':
        return const Color(0xFFE65100);
      case 'offer_letter':
        return const Color(0xFF7B1FA2);
      case 'accepted':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _progressBgColor(String progress) {
    switch (progress) {
      case 'none':
        return const Color(0xFFF5F5F5);
      case 'resume':
        return const Color(0xFFE3F2FD);
      case 'application':
        return const Color(0xFFFFF3E0);
      case 'offer_letter':
        return const Color(0xFFF3E5F5);
      case 'accepted':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String _progressLabel(String progress) {
    switch (progress) {
      case 'none':
        return 'None';
      case 'resume':
        return 'Resume';
      case 'application':
        return 'Application';
      case 'offer_letter':
        return 'Offer Letter';
      case 'accepted':
        return 'Accepted';
      default:
        return progress;
    }
  }

  void _showEditDialog(Student student) {
    String selectedProgress = student.progress;
    int selectedMentorId = student.universityMentor.userId;
    int? selectedSupervisorId = student.companySupervisor?.userId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Edit Student',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.user.fullname,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717182),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedProgress,
                          items: const [
                            DropdownMenuItem(value: 'none', child: Text('None')),
                            DropdownMenuItem(value: 'resume', child: Text('Resume')),
                            DropdownMenuItem(value: 'application', child: Text('Application')),
                            DropdownMenuItem(value: 'offer_letter', child: Text('Offer Letter')),
                            DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedProgress = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mentor',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedMentorId,
                          items: _mentors
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m.userId,
                                  child: Text(m.fullname),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedMentorId = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Company Supervisor',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: selectedSupervisorId,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('None', style: TextStyle(color: Color(0xFF9E9E9E))),
                            ),
                            ..._companySupervisors.map(
                              (s) => DropdownMenuItem<int?>(
                                value: s.user.userId,
                                child: Text('${s.user.fullname} (${s.company})'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() => selectedSupervisorId = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF717182)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    try {
                      if (selectedProgress != student.progress) {
                        await updateStudentProgress(
                          student.studentId,
                          selectedProgress,
                        );
                      }
                      if (selectedMentorId != student.universityMentor.userId) {
                        await updateStudentMentor(
                          student.studentId,
                          selectedMentorId,
                        );
                      }
                      final currentSupervisorId = student.companySupervisor?.userId;
                      if (selectedSupervisorId != currentSupervisorId) {
                        await updateStudentCompanySupervisor(
                          student.studentId,
                          selectedSupervisorId,
                        );
                      }
                      navigator.pop();
                      _fetchData();
                    } catch (e) {
                      navigator.pop();
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to update: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Color(0xFFC62828)),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _fetchData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Students',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage all registered students',
                        style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context.go('/admin/students/new'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Student'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_students.length} students',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF717182),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_students.isEmpty)
                        _buildEmpty()
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: _students.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _buildStudentCard(_students[index]),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: const Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          const Text(
            'No students found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a student to get started.',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF5F5F5),
            child: Text(
              student.user.fullname[0],
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
                  student.user.fullname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${student.studentId}  ·  ${student.fieldOfStudy}  ·  Year ${student.yearOfStudy}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mentor: ${student.universityMentor.fullname}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF717182),
                  ),
                ),
                if (student.companySupervisor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Supervisor: ${student.companySupervisor!.fullname}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF717182),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _progressBgColor(student.progress),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _progressLabel(student.progress),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _progressColor(student.progress),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => _showEditDialog(student),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: const Color(0xFF717182),
                tooltip: 'Edit student',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

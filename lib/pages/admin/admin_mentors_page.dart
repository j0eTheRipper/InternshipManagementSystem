import 'package:flutter/material.dart';
import 'package:internship_management_system/api/admin.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/models/user.dart';

class AdminMentorsPage extends StatefulWidget {
  const AdminMentorsPage({super.key});

  @override
  State<AdminMentorsPage> createState() => _AdminMentorsPageState();
}

class _AdminMentorsPageState extends State<AdminMentorsPage> {
  List<User> _mentors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final mentors = await getAllMentors();
      if (mounted) {
        setState(() {
          _mentors = mentors;
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

  void _showAddMentorDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Mentor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Color(0xFF717182)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter full name',
                      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter password (min 6 characters)',
                      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: submitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setSheetState(() => submitting = true);
                              final messenger = ScaffoldMessenger.of(context);
                              final dialogNav = Navigator.of(ctx);
                              try {
                                await createMentor(
                                  fullname: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                                if (mounted) {
                                  dialogNav.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Mentor created successfully'),
                                      backgroundColor: Color(0xFF2E7D32),
                                    ),
                                  );
                                  _fetchMentors();
                                }
                              } catch (e) {
                                setSheetState(() => submitting = false);
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Mentor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignStudents(User mentor) async {
    List<Student> allStudents = [];
    bool loading = true;

    try {
      allStudents = await getAllStudents();
    } catch (_) {}
    loading = false;

    if (!mounted) return;

    final assignedIds = <String>{
      for (final s in allStudents)
        if (s.universityMentor.userId == mentor.userId) s.studentId,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final assigned = allStudents
              .where((s) => assignedIds.contains(s.studentId))
              .toList();
          final unassigned = allStudents
              .where((s) => !assignedIds.contains(s.studentId))
              .toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor.fullname,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${assigned.length} student(s) assigned',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF717182),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Color(0xFF717182)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (assigned.isNotEmpty) ...[
                  const Text(
                    'Assigned Students',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF717182),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (assigned.isNotEmpty)
                  ...assigned.map(
                    (s) => _StudentToggle(
                      student: s,
                      assigned: true,
                      onToggle: () async {
                        try {
                          await updateStudentMentor(s.studentId, mentor.userId);
                          setSheetState(() => assignedIds.remove(s.studentId));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${s.user.fullname} unassigned'),
                                backgroundColor: const Color(0xFFE65100),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                if (assigned.isNotEmpty) const SizedBox(height: 16),
                if (unassigned.isNotEmpty) ...[
                  const Text(
                    'Available Students',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF717182),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (unassigned.isEmpty && assigned.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No students in the system.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  )
                else if (unassigned.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'All students are assigned.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  )
                else
                  ...unassigned.map(
                    (s) => _StudentToggle(
                      student: s,
                      assigned: false,
                      onToggle: () async {
                        try {
                          await updateStudentMentor(s.studentId, mentor.userId);
                          setSheetState(() => assignedIds.add(s.studentId));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${s.user.fullname} assigned'),
                                backgroundColor: const Color(0xFF2E7D32),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mentors',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage all mentors in the system',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717182),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _showAddMentorDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add Mentor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              _buildError()
            else if (_mentors.isEmpty)
              _buildEmpty()
            else
              ..._mentors.map(
                (mentor) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MentorCard(
                    mentor: mentor,
                    onTap: () => _showAssignStudents(mentor),
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
          'No mentors found.',
          style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            _error!,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: _fetchMentors,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A1A),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final User mentor;
  final VoidCallback? onTap;

  const _MentorCard({required this.mentor, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                  mentor.fullname[0].toUpperCase(),
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
                      mentor.fullname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mentor.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717182),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentToggle extends StatelessWidget {
  final Student student;
  final bool assigned;
  final VoidCallback onToggle;

  const _StudentToggle({
    required this.student,
    required this.assigned,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: assigned ? const Color(0xFFF1F8E9) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: assigned
              ? const Color(0xFFAED581)
              : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF5F5F5),
            child: Text(
              student.user.fullname[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF030213),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.user.fullname,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.fieldOfStudy} · ${student.studentId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717182),
                  ),
                ),
              ],
            ),
          ),
          if (!assigned)
            SizedBox(
              height: 32,
              child: FilledButton(
                onPressed: onToggle,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Assign', style: TextStyle(fontSize: 12)),
              ),
            )
          else
            SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: onToggle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Remove', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}

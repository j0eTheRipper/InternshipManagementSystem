import 'package:flutter/material.dart';
import 'package:internship_management_system/api/admin.dart';
import 'package:internship_management_system/models/student.dart';

class AdminAttendancePage extends StatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  State<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  List<Student> _students = [];
  Student? _selectedStudent;
  List<Map<String, dynamic>> _attendance = [];
  bool _loadingStudents = true;
  bool _loadingAttendance = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final students = await getAllStudents();
      if (mounted) {
        setState(() {
          _students = students;
          _loadingStudents = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStudents = false);
    }
  }

  Future<void> _fetchAttendance() async {
    if (_selectedStudent == null) return;
    setState(() => _loadingAttendance = true);
    try {
      final records = await getStudentAttendance(_selectedStudent!.studentId);
      if (mounted) {
        setState(() {
          _attendance = records;
          _loadingAttendance = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAttendance = false);
    }
  }

  Future<void> _addRecord() async {
    if (_selectedStudent == null) return;
    final startDate = _selectedStudent!.internshipStartDate != null
        ? DateTime.tryParse(_selectedStudent!.internshipStartDate!)
        : DateTime(2020);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final dateStr =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    try {
      await addAttendance(_selectedStudent!.studentId, dateStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance record added')),
        );
      }
      await _fetchAttendance();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add record: $e')),
        );
      }
    }
  }

  Future<void> _deleteRecord(int attendanceId) async {
    try {
      await deleteAttendance(attendanceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted')),
        );
      }
      await _fetchAttendance();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _loadingStudents
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Attendance Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'View and manage student attendance records',
                    style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                  ),
                  const SizedBox(height: 24),
                  _buildStudentDropdown(),
                  if (_selectedStudent != null) ...[
                    const SizedBox(height: 16),
                    _buildInternshipInfo(),
                  ],
                  const SizedBox(height: 24),
                  if (_selectedStudent != null)
                    Row(
                      children: [
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _addRecord,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Record'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
    );
  }

  Widget _buildStudentDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<Student>(
        initialValue: _selectedStudent,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Select a student',
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFF717182)),
        ),
        items: _students.map((s) {
          return DropdownMenuItem<Student>(
            value: s,
            child: Text(
              '${s.user.fullname} (${s.studentId})',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
          );
        }).toList(),
        onChanged: (student) {
          setState(() {
            _selectedStudent = student;
            _attendance = [];
          });
          _fetchAttendance();
        },
      ),
    );
  }

  Widget _buildInternshipInfo() {
    final s = _selectedStudent!;
    final startDate = s.internshipStartDate;
    final duration = s.internshipDurationWeeks;
    String? endDate;
    if (startDate != null && duration != null) {
      final start = DateTime.tryParse(startDate);
      if (start != null) {
        final end = start.add(Duration(days: duration * 7));
        endDate = _formatDate(end.toIso8601String().substring(0, 10));
      }
    }

    return Container(
      width: double.infinity,
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
          _infoChip(Icons.play_arrow_rounded, 'Start', startDate != null ? _formatDate(startDate) : 'Not set'),
          const SizedBox(width: 16),
          _infoChip(Icons.schedule_rounded, 'Duration', duration != null ? '$duration weeks' : 'Not set'),
          const SizedBox(width: 16),
          _infoChip(Icons.flag_rounded, 'End', endDate ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF717182)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedStudent == null) {
      return _buildEmptyState('Select a student');
    }
    if (_loadingAttendance) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_attendance.isEmpty) {
      return _buildEmptyState('No attendance records');
    }
    return ListView.separated(
      itemCount: _attendance.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildRecordCard(_attendance[index]),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              message == 'Select a student'
                  ? Icons.person_outline_rounded
                  : Icons.event_available_outlined,
              size: 48,
              color: const Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message == 'Select a student'
                  ? 'Choose a student from the dropdown to view their attendance.'
                  : 'Attendance records will appear here once available.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final bool attended = record['attended'] == true;
    final bool pending = record['pending'] == true;
    final int? id = record['attendance_id'];
    final String? checkedAt = record['checked_at'];
    final String date = record['date'] ?? '';

    final DateTime? dt = checkedAt != null ? DateTime.tryParse(checkedAt) : null;
    final String timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '';

    final Color statusColor;
    final String statusLabel;
    final Color iconBg;
    final Color iconFg;
    final IconData icon;

    if (attended) {
      statusColor = const Color(0xFFE8F5E9);
      statusLabel = 'Attended';
      iconBg = const Color(0xFFE8F5E9);
      iconFg = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline_rounded;
    } else if (pending) {
      statusColor = const Color(0xFFFFF3E0);
      statusLabel = 'Pending';
      iconBg = const Color(0xFFFFF3E0);
      iconFg = const Color(0xFFE65100);
      icon = Icons.schedule_rounded;
    } else {
      statusColor = const Color(0xFFFFEBEE);
      statusLabel = 'Absent';
      iconBg = const Color(0xFFFFEBEE);
      iconFg = const Color(0xFFC62828);
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconFg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (timeStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Checked in at $timeStr',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF717182),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: iconFg,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (id != null)
            IconButton(
              onPressed: () => _deleteRecord(id),
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Color(0xFFC62828),
              ),
              tooltip: 'Delete record',
            ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    if (month < 1 || month > 12 || day < 1) return isoDate;
    final dt = DateTime(year, month, day);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

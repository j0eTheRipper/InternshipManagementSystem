import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/chat.dart';
import 'package:internship_management_system/api/company_supervisor.dart';
import 'package:internship_management_system/auth/auth_state.dart';

class CompanySupervisorDashboard extends StatefulWidget {
  const CompanySupervisorDashboard({super.key});

  @override
  State<CompanySupervisorDashboard> createState() => _CompanySupervisorDashboardState();
}

class _CompanySupervisorDashboardState extends State<CompanySupervisorDashboard> {
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final students = await getAssignedStudents();
      if (mounted) setState(() { _students = students; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = AuthState.currentCompanySupervisor?.company ?? '';

    return Container(
      color: const Color(0xFFF8F9FA),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Company Supervisor Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.isNotEmpty ? company : 'Your dashboard',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        icon: Icons.people_outline,
                        label: 'Assigned Students',
                        value: '${_students.length}',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Pending Verifications',
                        value: '${_pendingVerifications()}',
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Assigned Students',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_students.isEmpty)
                    _buildEmptyState()
                  else
                    ..._students.map((s) => _buildStudentCard(s)),
                ],
              ),
            ),
    );
  }

  int _pendingVerifications() {
    int count = 0;
    for (final s in _students) {
      final att = s['attendance_summary'] as Map<String, dynamic>?;
      final wl = s['work_logs_summary'] as Map<String, dynamic>?;
      if (att != null) count += (att['total'] as int) - (att['verified'] as int);
      if (wl != null) count += (wl['total'] as int) - (wl['verified'] as int);
    }
    return count;
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF757575)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          Icon(Icons.people_outline, size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          const Text(
            'No students assigned yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Students will appear here once an admin assigns them to you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final user = student['user'] as Map<String, dynamic>;
    final name = user['fullname'] as String? ?? '';
    final userId = user['user_id'] as int? ?? 0;
    final fieldOfStudy = student['field_of_study'] as String? ?? '';
    final yearOfStudy = student['year_of_study'] as int? ?? 0;
    final studentId = student['student_id'] as String? ?? '';
    final attSummary = student['attendance_summary'] as Map<String, dynamic>?;
    final wlSummary = student['work_logs_summary'] as Map<String, dynamic>?;

    final attTotal = attSummary?['total'] as int? ?? 0;
    final attVerified = attSummary?['verified'] as int? ?? 0;
    final wlTotal = wlSummary?['total'] as int? ?? 0;
    final wlVerified = wlSummary?['verified'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompanySupervisorStudentDetailPage(studentId: studentId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF5F5F5),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF030213)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$fieldOfStudy · Year $yearOfStudy',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniBadge(
                            label: 'Attendance: $attVerified/$attTotal verified',
                            color: attTotal > 0 && attVerified == attTotal
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF57C00),
                          ),
                          const SizedBox(width: 8),
                          _buildMiniBadge(
                            label: 'Work Logs: $wlVerified/$wlTotal verified',
                            color: wlTotal > 0 && wlVerified == wlTotal
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF57C00),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      final conversationId = await createOrGetConversation(userId);
                      if (context.mounted) {
                        context.push('/chat/$conversationId');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  color: const Color(0xFF757575),
                  tooltip: 'Message student',
                ),
                Icon(Icons.chevron_right, size: 20, color: const Color(0xFFABABAB)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class CompanySupervisorStudentDetailPage extends StatefulWidget {
  final String studentId;

  const CompanySupervisorStudentDetailPage({super.key, required this.studentId});

  @override
  State<CompanySupervisorStudentDetailPage> createState() => _CompanySupervisorStudentDetailPageState();
}

class _CompanySupervisorStudentDetailPageState extends State<CompanySupervisorStudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _workLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final attendance = await getStudentAttendance(widget.studentId);
      final workLogs = await getStudentWorkLogs(widget.studentId);
      if (mounted) {
        setState(() {
          _attendance = attendance;
          _workLogs = workLogs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1A1A1A),
                    unselectedLabelColor: const Color(0xFF757575),
                    indicatorColor: const Color(0xFF1A1A1A),
                    tabs: const [
                      Tab(text: 'Attendance'),
                      Tab(text: 'Work Logs'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAttendanceTab(),
                      _buildWorkLogsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_attendance.isEmpty) {
      return _buildEmptyTab('No attendance records');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _attendance.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) => _AttendanceRow(
        record: _attendance[index],
        onChanged: _fetchData,
      ),
    );
  }

  Widget _buildWorkLogsTab() {
    if (_workLogs.isEmpty) {
      return _buildEmptyTab('No work log entries');
    }

    final grouped = _groupByWeek();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        final weekStart = entry.key;
        final tasks = entry.value;
        final weekNumber = _computeWeekNumber(weekStart);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(
                  'Week $weekNumber',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
              ),
              ...tasks.map((task) => _buildWorkLogRow(task)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkLogRow(Map<String, dynamic> task) {
    final dateStr = task['update_date'] as String? ?? '';
    final updateText = task['update_text'] as String? ?? '';
    final verified = task['verified'] == true;
    final dailyTaskId = task['daily_task_id'] as int?;
    final displayDate = _formatDate(dateStr);
    final preview = updateText.length > 20
        ? '${updateText.substring(0, 20)}…'
        : updateText;

    return InkWell(
      onTap: dailyTaskId != null
          ? () => _showWorkLogDetail(updateText, verified, dailyTaskId)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayDate,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF424242), height: 1.4),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: const Color(0xFFABABAB)),
          ],
        ),
      ),
    );
  }

  Future<void> _showWorkLogDetail(String updateText, bool verified, int dailyTaskId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        var isVerified = verified;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Work Log',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVerified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isVerified ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      updateText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          if (isVerified) {
                            await unverifyWorkLog(dailyTaskId);
                          } else {
                            await verifyWorkLog(dailyTaskId);
                          }
                          setModalState(() => isVerified = !isVerified);
                          _fetchData();
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: isVerified ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isVerified ? 'Unverify' : 'Verify',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVerificationBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: verified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        verified ? 'Verified' : 'Unverified',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: verified ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
        ),
      ),
    );
  }

  Widget _buildVerifyButton({required bool verified, required VoidCallback onToggle}) {
    return FilledButton(
      onPressed: onToggle,
      style: FilledButton.styleFrom(
        backgroundColor: verified ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
      ),
      child: Text(
        verified ? 'Unverify' : 'Verify',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupByWeek() {
    final Map<String, List<Map<String, dynamic>>> weeks = {};
    for (final task in _workLogs) {
      final weekKey = task['week_start_date'] as String? ?? 'unknown';
      weeks.putIfAbsent(weekKey, () => []);
      weeks[weekKey]!.add(task);
    }
    for (final entry in weeks.entries) {
      entry.value.sort((a, b) => (a['update_date'] ?? '').compareTo(b['update_date'] ?? ''));
    }
    final sortedKeys = weeks.keys.toList()..sort((a, b) => b.compareTo(a));
    final sorted = <String, List<Map<String, dynamic>>>{};
    for (final key in sortedKeys) {
      sorted[key] = weeks[key]!;
    }
    return sorted;
  }

  int _computeWeekNumber(String weekStartDate) {
    final parts = weekStartDate.split('-');
    if (parts.length != 3) return 0;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    if (year == 0) return 0;
    final start = DateTime(year, month, day);
    final jan4 = DateTime(year, 1, 4);
    final startOfIsoWeek = jan4.subtract(Duration(days: jan4.weekday - 1));
    final weeksDiff = ((start.difference(startOfIsoWeek).inDays) / 7).floor();
    return weeksDiff + 1;
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class CompanySupervisorStudentsPage extends StatefulWidget {
  const CompanySupervisorStudentsPage({super.key});

  @override
  State<CompanySupervisorStudentsPage> createState() => _CompanySupervisorStudentsPageState();
}

class _CompanySupervisorStudentsPageState extends State<CompanySupervisorStudentsPage> {
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _loading = true);
    try {
      final students = await getAssignedStudents();
      if (mounted) setState(() { _students = students; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'My Students',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Students assigned to you for verification',
                    style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 24),
                  if (_students.isEmpty)
                    _buildEmptyState()
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _students.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _buildStudentCard(_students[index]),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
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
          Icon(Icons.people_outline, size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          const Text(
            'No students assigned yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Students will appear here once an admin assigns them to you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final user = student['user'] as Map<String, dynamic>;
    final name = user['fullname'] as String? ?? '';
    final userId = user['user_id'] as int? ?? 0;
    final fieldOfStudy = student['field_of_study'] as String? ?? '';
    final yearOfStudy = student['year_of_study'] as int? ?? 0;
    final studentId = student['student_id'] as String? ?? '';
    final attSummary = student['attendance_summary'] as Map<String, dynamic>?;
    final wlSummary = student['work_logs_summary'] as Map<String, dynamic>?;

    final attTotal = attSummary?['total'] as int? ?? 0;
    final attVerified = attSummary?['verified'] as int? ?? 0;
    final wlTotal = wlSummary?['total'] as int? ?? 0;
    final wlVerified = wlSummary?['verified'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompanySupervisorStudentDetailPage(studentId: studentId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF5F5F5),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF030213)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$fieldOfStudy · Year $yearOfStudy',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniBadge(
                            label: 'Attendance: $attVerified/$attTotal verified',
                            color: attTotal > 0 && attVerified == attTotal
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF57C00),
                          ),
                          const SizedBox(width: 8),
                          _buildMiniBadge(
                            label: 'Work Logs: $wlVerified/$wlTotal verified',
                            color: wlTotal > 0 && wlVerified == wlTotal
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF57C00),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      final conversationId = await createOrGetConversation(userId);
                      if (context.mounted) {
                        context.push('/chat/$conversationId');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  color: const Color(0xFF757575),
                  tooltip: 'Message student',
                ),
                Icon(Icons.chevron_right, size: 20, color: const Color(0xFFABABAB)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _AttendanceRow extends StatefulWidget {
  final Map<String, dynamic> record;
  final VoidCallback onChanged;

  const _AttendanceRow({required this.record, required this.onChanged});

  @override
  State<_AttendanceRow> createState() => _AttendanceRowState();
}

class _AttendanceRowState extends State<_AttendanceRow> {
  bool _checkboxHovered = false;

  String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    if (month < 1 || month > 12 || day < 1) return isoDate;
    final dt = DateTime(year, month, day);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final checkedAt = record['checked_at'] as String?;
    final attended = checkedAt != null;
    final verified = record['verified'] == true;
    final dateStr = checkedAt != null ? checkedAt.substring(0, 10) : '';
    final attendanceId = record['attendance_id'] as int?;
    final displayDate = _formatDate(dateStr);

    return Material(
      color: verified ? Colors.white : const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: attended && attendanceId != null && !verified
            ? () async {
                await verifyAttendance(attendanceId);
                widget.onChanged();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: verified
                  ? const Color(0xFFE0E0E0).withValues(alpha: 0.5)
                  : const Color(0xFFFFE082).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              if (attended && attendanceId != null)
                MouseRegion(
                  onEnter: (_) => setState(() => _checkboxHovered = true),
                  onExit: (_) => setState(() => _checkboxHovered = false),
                  child: GestureDetector(
                    onTap: verified
                        ? () async {
                            await unverifyAttendance(attendanceId);
                            widget.onChanged();
                          }
                        : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: verified
                            ? (_checkboxHovered ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9))
                            : (_checkboxHovered ? const Color(0xFFFFF8E1) : Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: verified
                              ? (_checkboxHovered ? const Color(0xFFC62828) : const Color(0xFF2E7D32))
                              : const Color(0xFFBDBDBD),
                          width: _checkboxHovered ? 2 : 1,
                        ),
                      ),
                      child: verified
                          ? Icon(
                              _checkboxHovered ? Icons.close_rounded : Icons.check_rounded,
                              size: 18,
                              color: _checkboxHovered ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                            )
                          : null,
                    ),
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFFC62828),
                  ),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDate,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attended ? 'Checked in' : 'Missed',
                      style: TextStyle(
                        fontSize: 12,
                        color: attended ? const Color(0xFF9E9E9E) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

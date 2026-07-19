import 'package:flutter/material.dart';
import 'package:internship_management_system/api/attendance.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/api/daily_task.dart';
import 'package:internship_management_system/auth/auth_state.dart';

class InterningDashboard extends StatefulWidget {
  const InterningDashboard({super.key});

  @override
  State<InterningDashboard> createState() => _InterningDashboardState();
}

class _InterningDashboardState extends State<InterningDashboard> {
  String? _company;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final company = await getMyAcceptedCompany();
      if (mounted) {
        setState(() {
          _company = company;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _getCurrentWeek(DateTime startDate) {
    final now = DateTime.now();
    final diff = now.difference(startDate).inDays;
    final week = (diff / 7).floor() + 1;
    final totalWeeks = AuthState.currentStudent?.internshipDurationWeeks ?? 12;
    return week.clamp(1, totalWeeks);
  }

  @override
  Widget build(BuildContext context) {
    final student = AuthState.currentStudent;
    if (student == null) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loading) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return _InterningContent(
      company: _company,
      student: student,
      getCurrentWeek: _getCurrentWeek,
    );
  }
}

class _InterningContent extends StatefulWidget {
  final String? company;
  final dynamic student;
  final int Function(DateTime) getCurrentWeek;
  const _InterningContent({
    required this.company,
    required this.student,
    required this.getCurrentWeek,
  });

  @override
  State<_InterningContent> createState() => _InterningContentState();
}

class _InterningContentState extends State<_InterningContent> {
  bool _showDailyCheckIn = false;
  bool _showWeeklyCheckIn = false;
  bool _checkedInToday = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    try {
      final checkedIn = await getTodaysAttendance();
      if (mounted) setState(() => _checkedInToday = checkedIn);
    } catch (_) {}
  }

  void _showAlreadyCheckedInSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You have already checked in for today.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final startDate = DateTime.parse(student.internshipStartDate as String);
    final totalWeeks = student.internshipDurationWeeks as int;
    final week = widget.getCurrentWeek(startDate);
    final progress = week / totalWeeks;
    final weeksRemaining = totalWeeks - week;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchAttendance,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back,',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthState.currentUser?.fullname ?? 'Student',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 24),

                // Progress card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                              const SizedBox(width: 8),
                              Text(
                                'INTERNSHIP PROGRESS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$week of $totalWeeks weeks',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Week $week',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weeksRemaining == 1
                            ? '1 week remaining'
                            : '$weeksRemaining weeks remaining',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.business_rounded, size: 14, color: const Color(0xFF757575)),
                                const SizedBox(width: 6),
                                Text(
                                  'Company',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.company ?? 'Accepted',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school_rounded, size: 14, color: const Color(0xFF757575)),
                                const SizedBox(width: 6),
                                Text(
                                  'Mentor',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AuthState.currentStudent?.universityMentor.fullname ?? '—',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Company Supervisor card
                if (AuthState.currentStudent?.companySupervisor != null || AuthState.currentStudent?.companySupervisorName != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.supervisor_account_rounded, size: 14, color: const Color(0xFF757575)),
                            const SizedBox(width: 6),
                            Text(
                              'Company Supervisor',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AuthState.currentStudent!.companySupervisor?.fullname ??
                              AuthState.currentStudent!.companySupervisorName ??
                              '—',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (AuthState.currentStudent!.companySupervisorEmail != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            AuthState.currentStudent!.companySupervisorEmail!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                          ),
                        ],
                        if (AuthState.currentStudent!.companySupervisorPhone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            AuthState.currentStudent!.companySupervisorPhone!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // Actions
                Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF757575),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Daily Check-in
                _ActionCard(
                  icon: _checkedInToday ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  title: _checkedInToday ? 'Checked In' : 'Check In',
                  subtitle: _checkedInToday ? 'You have already checked in for today' : 'Log your daily attendance',
                  checkedIn: _checkedInToday,
                  onTap: _checkedInToday
                      ? () => _showAlreadyCheckedInSnackbar()
                      : () => setState(() => _showDailyCheckIn = true),
                ),
                const SizedBox(height: 8),

                // Daily Task
                _ActionCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Daily Task',
                  subtitle: 'Log what you worked on today',
                  onTap: () => setState(() => _showWeeklyCheckIn = true),
                ),
              ],
            ),
          ),
          ),

          // Daily check-in overlay
          if (_showDailyCheckIn)
            _DailyCheckInModal(
              onClose: () => setState(() => _showDailyCheckIn = false),
              onCheckedIn: () { _checkedInToday = true; },
            ),

          // Daily task overlay
          if (_showWeeklyCheckIn)
            _DailyTaskModal(
              onClose: () => setState(() => _showWeeklyCheckIn = false),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool checkedIn;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.checkedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checkedIn ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: checkedIn ? const Color(0xFF2E7D32) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: checkedIn
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Icon(icon, size: 20, color: checkedIn ? Colors.white : const Color(0xFF1A1A1A)),
              ),
              const SizedBox(width: 16),
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
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: const Color(0xFFABABAB)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyCheckInModal extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onCheckedIn;

  const _DailyCheckInModal({required this.onClose, this.onCheckedIn});

  @override
  State<_DailyCheckInModal> createState() => _DailyCheckInModalState();
}

class _DailyCheckInModalState extends State<_DailyCheckInModal> {
  bool _saving = false;
  bool? _success;

  Future<void> _doCheckIn() async {
    setState(() => _saving = true);
    try {
      await checkIn();
      if (mounted) {
        setState(() {
          _success = true;
          _saving = false;
        });
        widget.onCheckedIn?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitted = _success != null;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: GestureDetector(
          onTap: () {},
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSubmitted
                  ? Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: const Color(0xFF1A1A1A)),
                          const SizedBox(height: 20),
                          const Text(
                            'Check-in recorded',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your attendance has been logged for today.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: widget.onClose,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF030213),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Done', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Check-in',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Log your attendance for today.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saving ? null : widget.onClose,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF757575),
                                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _saving ? null : _doCheckIn,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF030213),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Check In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyTaskModal extends StatefulWidget {
  final VoidCallback onClose;

  const _DailyTaskModal({required this.onClose});

  @override
  State<_DailyTaskModal> createState() => _DailyTaskModalState();
}

class _DailyTaskModalState extends State<_DailyTaskModal> {
  bool _submitted = false;
  bool _saving = false;
  final _updateController = TextEditingController();

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await submitDailyTask(updateText: _updateController.text.trim());
      if (mounted) setState(() { _submitted = true; _saving = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: GestureDetector(
          onTap: () {},
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _submitted
                  ? Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: const Color(0xFF1A1A1A)),
                          const SizedBox(height: 20),
                          const Text(
                            'Daily task submitted',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your daily update has been recorded.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: widget.onClose,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF030213),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Done', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Task',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What did you work on today?',
                            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _updateController,
                            maxLines: 5,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'e.g. Built the login page, fixed a bug in the API...',
                              hintStyle: const TextStyle(color: Color(0xFFABABAB)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF030213)),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: widget.onClose,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF757575),
                                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _updateController.text.trim().isNotEmpty && !_saving
                                      ? _submit
                                      : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF030213),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Submit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

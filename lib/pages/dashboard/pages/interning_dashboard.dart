import 'package:flutter/material.dart';
import 'package:internship_management_system/api/student.dart';
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

    if (student.internshipStartDate == null) {
      return _InternshipSetupForm(
        onComplete: () async {
          final userId = AuthState.currentUser?.userId;
          if (userId != null) {
            try {
              final updated = await getStudent(userId.toString());
              AuthState.updateStudentData(updated);
            } catch (_) {}
          }
          if (mounted) setState(() {});
        },
      );
    }

    return _InterningContent(
      company: _company,
      student: student,
      getCurrentWeek: _getCurrentWeek,
    );
  }
}

class _InternshipSetupForm extends StatefulWidget {
  final VoidCallback onComplete;

  const _InternshipSetupForm({required this.onComplete});

  @override
  State<_InternshipSetupForm> createState() => _InternshipSetupFormState();
}

class _InternshipSetupFormState extends State<_InternshipSetupForm> {
  DateTime? _startDate;
  int _durationWeeks = 12;
  bool _saving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _save() async {
    if (_startDate == null) return;
    setState(() => _saving = true);
    try {
      final formatted =
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
      await updateInternshipDetails(
        startDate: formatted,
        durationWeeks: _durationWeeks,
      );
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.today_rounded,
                  size: 40,
                  color: const Color(0xFF030213),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Set Up Your Internship',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us when your internship starts and how long it lasts so we can track your progress.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Start date',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: const Color(0xFF717182)),
                        const SizedBox(width: 12),
                        Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 14,
                            color: _startDate != null ? const Color(0xFF1A1A1A) : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Duration (weeks)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _durationWeeks > 1
                          ? () => setState(() => _durationWeeks--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: const Color(0xFF030213),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_durationWeeks',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _durationWeeks < 52
                          ? () => setState(() => _durationWeeks++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: const Color(0xFF030213),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _startDate != null && !_saving ? _save : null,
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
                        : const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final startDateStr = student.internshipStartDate as String;
    final startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
    final totalWeeks = student.internshipDurationWeeks as int? ?? 12;
    final week = widget.getCurrentWeek(startDate);
    final progress = week / totalWeeks;
    final weeksRemaining = totalWeeks - week;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Stack(
        children: [
          SingleChildScrollView(
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
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Check In',
                  subtitle: 'Log your daily attendance',
                  onTap: () => setState(() => _showDailyCheckIn = true),
                ),
                const SizedBox(height: 8),

                // Weekly Check-in
                _ActionCard(
                  icon: Icons.assignment_outlined,
                  title: 'Weekly Check-in',
                  subtitle: 'Week $week reflection & rating',
                  onTap: () => setState(() => _showWeeklyCheckIn = true),
                ),
              ],
            ),
          ),

          // Daily check-in overlay
          if (_showDailyCheckIn)
            _DailyCheckInModal(onClose: () => setState(() => _showDailyCheckIn = false)),

          // Weekly check-in overlay
          if (_showWeeklyCheckIn)
            _WeeklyCheckInModal(
              week: week,
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

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
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

  const _DailyCheckInModal({required this.onClose});

  @override
  State<_DailyCheckInModal> createState() => _DailyCheckInModalState();
}

class _DailyCheckInModalState extends State<_DailyCheckInModal> {
  bool _submitted = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                            'Log your attendance and a quick note for today.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _controller,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'What are you working on today?',
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
                                  onPressed: _controller.text.trim().isNotEmpty
                                      ? () => setState(() => _submitted = true)
                                      : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF030213),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Submit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

class _WeeklyCheckInModal extends StatefulWidget {
  final int week;
  final VoidCallback onClose;

  const _WeeklyCheckInModal({required this.week, required this.onClose});

  @override
  State<_WeeklyCheckInModal> createState() => _WeeklyCheckInModalState();
}

class _WeeklyCheckInModalState extends State<_WeeklyCheckInModal> {
  bool _submitted = false;
  final _tasksController = TextEditingController();
  final _learningsController = TextEditingController();

  @override
  void dispose() {
    _tasksController.dispose();
    _learningsController.dispose();
    super.dispose();
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
                          Text(
                            'Week ${widget.week} report submitted',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your mentor will review your weekly report.',
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
                          Text(
                            'Week ${widget.week} Check-in',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'List what you worked on and what you learned this week.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tasks completed',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tasksController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'e.g. Built the auth flow, attended sprint planning...',
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
                          const Text(
                            'Learning points',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _learningsController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'e.g. Learned how JWT refresh tokens work...',
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
                                  onPressed: _tasksController.text.trim().isNotEmpty &&
                                          _learningsController.text.trim().isNotEmpty
                                      ? () => setState(() => _submitted = true)
                                      : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF030213),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Submit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

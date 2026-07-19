import 'package:flutter/material.dart';
import 'package:internship_management_system/api/daily_task.dart';

class WorkLogsPage extends StatefulWidget {
  const WorkLogsPage({super.key});

  @override
  State<WorkLogsPage> createState() => _WorkLogsPageState();
}

class _WorkLogsPageState extends State<WorkLogsPage> {
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  String? _editingDate;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final history = await getDailyTaskHistory();
      if (mounted) {
        setState(() {
          _tasks = history.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByWeek() {
    final Map<String, List<Map<String, dynamic>>> weeks = {};
    for (final task in _tasks) {
      final weekKey = task['week_start_date'] as String? ?? 'unknown';
      weeks.putIfAbsent(weekKey, () => []);
      weeks[weekKey]!.add(task);
    }
    for (final entry in weeks.entries) {
      entry.value.sort((a, b) => (a['update_date'] ?? '').compareTo(b['update_date'] ?? ''));
    }
    final sortedKeys = weeks.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final sorted = <String, List<Map<String, dynamic>>>{};
    for (final key in sortedKeys) {
      sorted[key] = weeks[key]!;
    }
    return sorted;
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
                    'Work Logs',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your daily task updates',
                    style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 24),
                  if (_tasks.isEmpty)
                    _buildEmptyState()
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchTasks,
                        child: ListView(
                          children: _buildWeekCards(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildWeekCards() {
    final grouped = _groupByWeek();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final List<Widget> cards = [];

    for (final entry in grouped.entries) {
      final weekStart = entry.key;
      final tasks = entry.value;
      final weekEnd = tasks.isNotEmpty
          ? (tasks.last['week_end_date'] as String? ?? '')
          : '';

      final weekNumber = _computeWeekNumber(weekStart);
      final startDisplay = _formatShortDate(weekStart);
      final endDisplay = _formatShortDate(weekEnd);

      cards.add(
        Container(
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
                child: Row(
                  children: [
                    Icon(Icons.date_range_rounded, size: 16, color: const Color(0xFF1A1A1A).withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Text(
                      'Week $weekNumber',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$startDisplay – $endDisplay',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${tasks.length} day${tasks.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              ...tasks.map((task) => _DayEntry(
                task: task,
                isToday: (task['update_date'] as String?) == today,
                isEditing: _editingDate == task['update_date'],
                onEdit: () => setState(() => _editingDate = task['update_date']),
                onCancel: () => setState(() => _editingDate = null),
                onSaved: () {
                  setState(() => _editingDate = null);
                  _fetchTasks();
                },
              )),
            ],
          ),
        ),
      );
    }

    return cards;
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
          Icon(Icons.edit_note_rounded, size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          const Text(
            'No work logs yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your daily task updates will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

class _DayEntry extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isToday;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const _DayEntry({
    required this.task,
    required this.isToday,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<_DayEntry> createState() => _DayEntryState();
}

class _DayEntryState extends State<_DayEntry> {
  late TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task['update_text'] as String? ?? '');
  }

  @override
  void didUpdateWidget(covariant _DayEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      _controller.text = widget.task['update_text'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    try {
      await submitDailyTask(updateText: text);
      if (mounted) widget.onSaved();
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
    final dateStr = widget.task['update_date'] as String? ?? '';
    final updateText = widget.task['update_text'] as String? ?? '';
    final submittedAt = widget.task['submitted_at'] as String?;
    final displayDate = _formatFullDate(dateStr);

    String timeStr = '';
    if (submittedAt != null) {
      final dt = DateTime.tryParse(submittedAt);
      if (dt != null) {
        timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: widget.isEditing ? _buildEditing(timeStr) : _buildDisplay(displayDate, timeStr, updateText),
    );
  }

  Widget _buildDisplay(String displayDate, String timeStr, String updateText) {
    final verified = widget.task['verified'] == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check_rounded, size: 18, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    displayDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
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
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                updateText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF424242),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (timeStr.isNotEmpty)
              Text(
                timeStr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            if (widget.isToday) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: widget.onEdit,
                child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF757575)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEditing(String timeStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF1565C0)),
            ),
            const SizedBox(width: 14),
            Text(
              'Editing today\'s update',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1565C0),
              ),
            ),
            if (timeStr.isNotEmpty) ...[
              const Spacer(),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'What did you work on today?',
            hintStyle: const TextStyle(color: Color(0xFFABABAB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1565C0)),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF757575),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _controller.text.trim().isNotEmpty && !_saving ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatFullDate(String isoDate) {
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

String _formatShortDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  final month = int.tryParse(parts[1]) ?? 0;
  final day = int.tryParse(parts[2]) ?? 0;
  if (month < 1 || month > 12 || day < 1) return isoDate;
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[month - 1]} $day';
}

int _computeWeekNumber(String weekStartDate) {
  final parts = weekStartDate.split('-');
  if (parts.length != 3) return 0;
  final year = int.tryParse(parts[0]) ?? 0;
  final month = int.tryParse(parts[1]) ?? 0;
  final day = int.tryParse(parts[2]) ?? 0;
  if (year == 0) return 0;
  final start = DateTime(year, month, day);
  final internshipStart = DateTime(start.year, 1, 1);
  while (internshipStart.weekday > 1) {
    // This is just a rough week number from the start of the year.
    // We compute from the date itself for display.
    break;
  }
  // Use ISO week number as a simple display label
  final jan4 = DateTime(year, 1, 4);
  final startOfIsoWeek = jan4.subtract(Duration(days: jan4.weekday - 1));
  final weeksDiff = ((start.difference(startOfIsoWeek).inDays) / 7).floor();
  return weeksDiff + 1;
}

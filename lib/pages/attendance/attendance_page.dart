import 'package:flutter/material.dart';
import 'package:internship_management_system/api/attendance.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final history = await getAttendanceHistory();
      if (mounted) setState(() { _history = history; _loading = false; });
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
                    'Attendance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your daily check-in history',
                    style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 24),
                  _buildSummary(),
                  const SizedBox(height: 16),
                  if (_history.isEmpty)
                    _buildEmptyState()
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchHistory,
                        child: ListView.separated(
                          itemCount: _history.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 4),
                          itemBuilder: (context, index) => _buildRow(_history[index]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary() {
    final attended = _history.where((r) => r['attended'] == true).length;
    final total = _history.length;
    final rate = total > 0 ? attended / total : 0.0;

    return Container(
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
              Icon(Icons.bar_chart_rounded, size: 18, color: const Color(0xFF1A1A1A).withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Text(
                '$attended of $total days attended',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Text(
                '${(rate * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 0.8 ? const Color(0xFF2E7D32) : rate >= 0.5 ? const Color(0xFFF57C00) : const Color(0xFFC62828),
              ),
              minHeight: 6,
            ),
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
          Icon(Icons.event_available_outlined, size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          const Text(
            'No attendance records yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your check-ins will appear here once you start tracking attendance.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> record) {
    final attended = record['attended'] == true;
    final pending = record['pending'] == true;
    final verified = record['verified'] == true;
    final dateStr = record['date'] as String;

    DateTime? dt;
    final checkedAt = record['checked_at'] as String?;
    if (checkedAt != null) dt = DateTime.tryParse(checkedAt);

    final displayDate = _formatDate(dateStr);
    final timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '';

    final Color bgColor;
    final Color iconBgColor;
    final Color iconColor;
    final IconData icon;
    final String label;

    if (attended) {
      bgColor = Colors.white;
      iconBgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      icon = Icons.check_rounded;
      label = 'Checked in';
    } else if (pending) {
      bgColor = const Color(0xFFFFF8E1);
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFF57C00);
      icon = Icons.schedule_rounded;
      label = 'Pending';
    } else {
      bgColor = Colors.white;
      iconBgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
      icon = Icons.close_rounded;
      label = 'Missed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: attended
                        ? const Color(0xFF9E9E9E)
                        : pending
                            ? const Color(0xFFF57C00)
                            : const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
          ),
          if (timeStr.isNotEmpty)
            Text(
              timeStr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
          if (attended && !pending) ...[
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
        ],
      ),
    );
  }
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

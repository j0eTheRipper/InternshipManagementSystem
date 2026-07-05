import 'package:flutter/material.dart';
import 'package:internship_management_system/api/offer_letter.dart';
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/models/resume.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/open_pdf.dart';

class StudentDocumentsPage extends StatefulWidget {
  const StudentDocumentsPage({super.key});

  @override
  State<StudentDocumentsPage> createState() => _StudentDocumentsPageState();
}

class _StudentDocumentsPageState extends State<StudentDocumentsPage> {
  List<Student> _students = [];
  Map<String, List<ResumeData>> _resumeCache = {};
  Map<String, List<Map<String, dynamic>>> _offerLetterCache = {};
  String? _expandedStudentId;
  final Map<String, bool> _openingPdf = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final students = await getMentorStudents();

      final allOfferLetters = await getMentorOfferLetters();
      final offerLetterMap = <String, List<Map<String, dynamic>>>{};
      for (final ol in allOfferLetters) {
        final sid = ol['student_id'] as String;
        offerLetterMap.putIfAbsent(sid, () => []).add(ol as Map<String, dynamic>);
      }

      final resumeCache = <String, List<ResumeData>>{};
      for (final s in students) {
        try {
          resumeCache[s.studentId] = await getResume(studentId: s.studentId);
        } catch (_) {
          resumeCache[s.studentId] = [];
        }
      }

      if (mounted) {
        setState(() {
          _students = students;
          _resumeCache = resumeCache;
          _offerLetterCache = offerLetterMap;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _shouldShowStudent(Student student) {
    final resumes = _resumeCache[student.studentId] ?? [];
    final offerLetters = _offerLetterCache[student.studentId] ?? [];

    final hasUnverifiedResume = resumes.any((r) => !r.verified);
    final hasUnverifiedOfferLetter = offerLetters.any((ol) => ol['verified'] != true);

    if (hasUnverifiedResume || hasUnverifiedOfferLetter) return true;
    if (resumes.isEmpty && offerLetters.isEmpty) return true;
    return false;
  }

  String _studentStatus(Student student) {
    final resumes = _resumeCache[student.studentId] ?? [];
    final offerLetters = _offerLetterCache[student.studentId] ?? [];

    final hasUnverifiedResume = resumes.any((r) => !r.verified);
    final hasUnverifiedOfferLetter = offerLetters.any((ol) => ol['verified'] != true);

    if (hasUnverifiedResume || hasUnverifiedOfferLetter) return 'Pending Review';
    if (resumes.isEmpty && offerLetters.isEmpty) return 'No Documents';
    return 'Complete';
  }

  Future<void> _viewResume(int resumeId, String studentId) async {
    final key = 'resume:$studentId:$resumeId';
    setState(() => _openingPdf[key] = true);
    try {
      final bytes = await downloadResume(resumeId);
      openPdfInBrowser(bytes, fileName: 'resume_$resumeId.pdf');
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
    if (mounted) setState(() => _openingPdf[key] = false);
  }

  Future<void> _viewOfferLetter(int offerLetterId) async {
    final key = 'ol:$offerLetterId';
    setState(() => _openingPdf[key] = true);
    try {
      final bytes = await downloadOfferLetter(offerLetterId);
      openPdfInBrowser(bytes, fileName: 'offer_letter_$offerLetterId.pdf');
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
    if (mounted) setState(() => _openingPdf[key] = false);
  }

  Future<void> _approveResume(int resumeId) async {
    try {
      await approveResume(resumeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume approved'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      _fetchData();
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
  }

  Future<void> _approveOfferLetter(int offerLetterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve offer letter'),
        content: const Text('Are you sure you want to approve this offer letter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await approveOfferLetter(offerLetterId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer letter approved')),
        );
      }
      _fetchData();
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
  }

  Future<void> _rejectOfferLetter(int offerLetterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject offer letter'),
        content: const Text('Are you sure you want to reject this offer letter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await rejectOfferLetter(offerLetterId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer letter rejected')),
        );
      }
      _fetchData();
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
  }

  @override
  Widget build(BuildContext context) {
    final shown = _students.where(_shouldShowStudent).toList();

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Documents',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review resumes and offer letters submitted by your students',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (shown.isEmpty)
              _buildEmpty()
            else
              ...shown.map((s) => _buildStudentCard(s)),
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
          'No students require document review at this time.',
          style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final resumes = _resumeCache[student.studentId] ?? [];
    final offerLetters = _offerLetterCache[student.studentId] ?? [];
    final isExpanded = _expandedStudentId == student.studentId;
    final status = _studentStatus(student);

    final pendingResumes = resumes.where((r) => !r.verified).toList();
    final reviewedResumes = resumes.where((r) => r.verified).toList();
    final pendingOfferLetters = offerLetters.where((ol) => ol['verified'] != true).toList();
    final reviewedOfferLetters = offerLetters.where((ol) => ol['verified'] == true).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _expandedStudentId = isExpanded ? null : student.studentId;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFF5F5F5),
                      child: Text(
                        student.user.fullname.isNotEmpty
                            ? student.user.fullname[0].toUpperCase()
                            : '?',
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
                          const SizedBox(height: 4),
                          Text(
                            '${student.fieldOfStudy} · Year ${student.yearOfStudy}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF717182),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: status),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF717182),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pendingResumes.isNotEmpty || pendingOfferLetters.isNotEmpty) ...[
                      const Text(
                        'Pending Reviews',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pendingResumes.map(
                        (r) => _ResumeRow(
                          resume: r,
                          studentId: student.studentId,
                          openingPdf: _openingPdf,
                          onView: () => _viewResume(r.resumeId, student.studentId),
                          onApprove: () => _approveResume(r.resumeId),
                        ),
                      ),
                      ...pendingOfferLetters.map(
                        (ol) => _OfferLetterRow(
                          offerLetter: ol,
                          openingPdf: _openingPdf,
                          onView: () => _viewOfferLetter(ol['offer_letter_id'] as int),
                          onApprove: () => _approveOfferLetter(ol['offer_letter_id'] as int),
                          onReject: () => _rejectOfferLetter(ol['offer_letter_id'] as int),
                        ),
                      ),
                      if (reviewedResumes.isNotEmpty || reviewedOfferLetters.isNotEmpty)
                        const SizedBox(height: 20),
                    ],
                    if (reviewedResumes.isNotEmpty || reviewedOfferLetters.isNotEmpty) ...[
                      const Text(
                        'Reviewed Documents',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...reviewedResumes.map(
                        (r) => _ResumeRow(
                          resume: r,
                          studentId: student.studentId,
                          openingPdf: _openingPdf,
                          onView: () => _viewResume(r.resumeId, student.studentId),
                        ),
                      ),
                      ...reviewedOfferLetters.map(
                        (ol) => _OfferLetterRow(
                          offerLetter: ol,
                          openingPdf: _openingPdf,
                          onView: () => _viewOfferLetter(ol['offer_letter_id'] as int),
                        ),
                      ),
                    ],
                    if (resumes.isEmpty && offerLetters.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No documents uploaded yet.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Pending Review':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
      case 'No Documents':
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF9E9E9E);
      default:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _ResumeRow extends StatelessWidget {
  final ResumeData resume;
  final String studentId;
  final Map<String, bool> openingPdf;
  final VoidCallback onView;
  final VoidCallback? onApprove;

  const _ResumeRow({
    required this.resume,
    required this.studentId,
    required this.openingPdf,
    required this.onView,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final key = 'resume:$studentId:${resume.resumeId}';
    final opening = openingPdf[key] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 18,
            color: const Color(0xFF030213).withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume #${resume.resumeId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  resume.verified ? 'Approved' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: resume.verified
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: opening ? null : onView,
            icon: opening
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.visibility_outlined, size: 16),
            label: Text(opening ? 'Opening...' : 'View'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF030213),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
          if (onApprove != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onApprove,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
              ),
              child: const Text('Approve'),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferLetterRow extends StatelessWidget {
  final Map<String, dynamic> offerLetter;
  final Map<String, bool> openingPdf;
  final VoidCallback onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _OfferLetterRow({
    required this.offerLetter,
    required this.openingPdf,
    required this.onView,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final olId = offerLetter['offer_letter_id'] as int;
    final key = 'ol:$olId';
    final opening = openingPdf[key] == true;
    final isVerified = offerLetter['verified'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.mail_outline_rounded,
            size: 18,
            color: const Color(0xFF030213).withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offerLetter['opportunity_title'] ?? 'Offer Letter',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  isVerified ? 'Approved' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: isVerified
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: opening ? null : onView,
            icon: opening
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new, size: 16),
            label: Text(opening ? 'Opening...' : 'View'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF030213),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
          if (onApprove != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onApprove,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
              ),
              child: const Text('Approve'),
            ),
          ],
          if (onReject != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onReject,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
              ),
              child: const Text('Reject'),
            ),
          ],
        ],
      ),
    );
  }
}

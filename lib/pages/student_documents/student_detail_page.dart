import 'package:flutter/material.dart';
import 'package:internship_management_system/api/offer_letter.dart';
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/models/resume.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/open_pdf.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;

  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  Student? _student;
  String? _company;
  List<ResumeData> _resumes = [];
  List<dynamic> _offerLetters = [];
  bool _loading = true;
  final Map<String, bool> _openingPdf = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final students = await getMentorStudents();
      final student = students.cast<Student?>().firstWhere(
        (s) => s!.studentId == widget.studentId,
        orElse: () => null,
      );

      String? company;
      if (student != null && student.progress == 'accepted') {
        try {
          company = await getAcceptedCompany(student.studentId);
        } catch (_) {}
      }

      List<ResumeData> resumes = [];
      List<dynamic> offerLetters = [];

      if (student != null) {
        try {
          resumes = await getResume(studentId: student.studentId);
        } catch (_) {
          resumes = [];
        }
        try {
          offerLetters = await getStudentOfferLetters(student.studentId);
        } catch (_) {
          offerLetters = [];
        }
      }

      if (mounted) {
        setState(() {
          _student = student;
          _company = company;
          _resumes = resumes;
          _offerLetters = offerLetters;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusFromProgress(String progress) {
    switch (progress) {
      case 'resume':
      case 'offer_letter':
        return 'Pending Review';
      default:
        return 'Active';
    }
  }

  Future<void> _viewResume(int resumeId) async {
    final key = 'resume:$resumeId';
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
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _student == null
              ? _buildNotFound()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildDocumentsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Student not found',
            style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final student = _student!;
    final status = _statusFromProgress(student.progress);

    Color statusBg;
    Color statusFg;
    if (status == 'Pending Review') {
      statusBg = const Color(0xFFFFF3E0);
      statusFg = const Color(0xFFE65100);
    } else {
      statusBg = const Color(0xFFE8F5E9);
      statusFg = const Color(0xFF2E7D32);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFF5F5F5),
            child: Text(
              student.user.fullname.isNotEmpty
                  ? student.user.fullname[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF030213),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.user.fullname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _company != null
                      ? '${student.fieldOfStudy} · Year ${student.yearOfStudy} · Accepted at $_company'
                      : '${student.fieldOfStudy} · Year ${student.yearOfStudy}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mentor: ${student.universityMentor.fullname}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusFg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final pendingResumes = _resumes.where((r) => !r.verified).toList();
    final reviewedResumes = _resumes.where((r) => r.verified).toList();
    final pendingOfferLetters = _offerLetters.where((ol) => ol['verified'] != true).toList();
    final reviewedOfferLetters = _offerLetters.where((ol) => ol['verified'] == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        if (_resumes.isEmpty && _offerLetters.isEmpty)
          Container(
            width: double.infinity,
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
                'No documents uploaded yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
              ),
            ),
          )
        else ...[
          if (pendingResumes.isNotEmpty || pendingOfferLetters.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending Reviews',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...pendingResumes.map(
                    (r) => _DocumentRow(
                      icon: Icons.description_outlined,
                      title: 'Resume #${r.resumeId}',
                      subtitle: 'Pending',
                      subtitleColor: const Color(0xFFE65100),
                      openingPdf: _openingPdf,
                      pdfKey: 'resume:${r.resumeId}',
                      onView: () => _viewResume(r.resumeId),
                      actionLabel: 'Approve',
                      actionColor: const Color(0xFF2E7D32),
                      onAction: () => _approveResume(r.resumeId),
                    ),
                  ),
                  ...pendingOfferLetters.map(
                    (ol) => _DocumentRow(
                      icon: Icons.mail_outline_rounded,
                      title: ol['opportunity_title'] ?? 'Offer Letter',
                      subtitle: 'Pending',
                      subtitleColor: const Color(0xFFE65100),
                      openingPdf: _openingPdf,
                      pdfKey: 'ol:${ol['offer_letter_id']}',
                      onView: () => _viewOfferLetter(ol['offer_letter_id'] as int),
                      actionLabel: 'Approve',
                      actionColor: const Color(0xFF2E7D32),
                      onAction: () => _approveOfferLetter(ol['offer_letter_id'] as int),
                      secondaryActionLabel: 'Reject',
                      secondaryActionColor: const Color(0xFFC62828),
                      onSecondaryAction: () => _rejectOfferLetter(ol['offer_letter_id'] as int),
                    ),
                  ),
                ],
              ),
            ),
            if (reviewedResumes.isNotEmpty || reviewedOfferLetters.isNotEmpty)
              const SizedBox(height: 16),
          ],
          if (reviewedResumes.isNotEmpty || reviewedOfferLetters.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviewed Documents',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reviewedResumes.map(
                    (r) => _DocumentRow(
                      icon: Icons.description_outlined,
                      title: 'Resume #${r.resumeId}',
                      subtitle: 'Approved',
                      subtitleColor: const Color(0xFF2E7D32),
                      openingPdf: _openingPdf,
                      pdfKey: 'resume:${r.resumeId}',
                      onView: () => _viewResume(r.resumeId),
                    ),
                  ),
                  ...reviewedOfferLetters.map(
                    (ol) => _DocumentRow(
                      icon: Icons.mail_outline_rounded,
                      title: ol['opportunity_title'] ?? 'Offer Letter',
                      subtitle: 'Approved',
                      subtitleColor: const Color(0xFF2E7D32),
                      openingPdf: _openingPdf,
                      pdfKey: 'ol:${ol['offer_letter_id']}',
                      onView: () => _viewOfferLetter(ol['offer_letter_id'] as int),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Map<String, bool> openingPdf;
  final String pdfKey;
  final VoidCallback onView;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final Color? secondaryActionColor;
  final VoidCallback? onSecondaryAction;

  const _DocumentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.openingPdf,
    required this.pdfKey,
    required this.onView,
    this.actionLabel,
    this.actionColor,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionColor,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final opening = openingPdf[pdfKey] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF030213).withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: actionColor ?? const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              child: Text(actionLabel ?? 'Approve'),
            ),
          ],
          if (onSecondaryAction != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onSecondaryAction,
              style: FilledButton.styleFrom(
                backgroundColor: secondaryActionColor ?? const Color(0xFFC62828),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              child: Text(secondaryActionLabel ?? 'Reject'),
            ),
          ],
        ],
      ),
    );
  }
}

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
                if (student.companySupervisor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Supervisor: ${student.companySupervisor!.fullname}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
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

    final hasResumes = _resumes.isNotEmpty;
    final hasOfferLetters = _offerLetters.isNotEmpty;

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
        if (!hasResumes && !hasOfferLetters)
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
          if (hasResumes) _buildTypeSection(
            title: 'Resumes',
            icon: Icons.description_outlined,
            pendingList: pendingResumes.map((r) => _DocumentItem(
              key: 'resume:${r.resumeId}',
              title: 'Resume #${r.resumeId}',
              onView: () => _viewResume(r.resumeId),
              onApprove: () => _approveResume(r.resumeId),
            )).toList(),
            reviewedList: reviewedResumes.map((r) => _DocumentItem(
              key: 'resume:${r.resumeId}',
              title: 'Resume #${r.resumeId}',
              onView: () => _viewResume(r.resumeId),
            )).toList(),
          ),
          if (hasResumes && hasOfferLetters) const SizedBox(height: 20),
          if (hasOfferLetters) _buildTypeSection(
            title: 'Offer Letters',
            icon: Icons.mail_outline_rounded,
            pendingList: pendingOfferLetters.map((ol) => _DocumentItem(
              key: 'ol:${ol['offer_letter_id']}',
              title: ol['opportunity_title'] ?? 'Offer Letter',
              onView: () => _viewOfferLetter(ol['offer_letter_id'] as int),
              onApprove: () => _approveOfferLetter(ol['offer_letter_id'] as int),
              onReject: () => _rejectOfferLetter(ol['offer_letter_id'] as int),
            )).toList(),
            reviewedList: reviewedOfferLetters.map((ol) => _DocumentItem(
              key: 'ol:${ol['offer_letter_id']}',
              title: ol['opportunity_title'] ?? 'Offer Letter',
              onView: () => _viewOfferLetter(ol['offer_letter_id'] as int),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeSection({
    required String title,
    required IconData icon,
    required List<_DocumentItem> pendingList,
    required List<_DocumentItem> reviewedList,
  }) {
    final hasPending = pendingList.isNotEmpty;
    final hasReviewed = reviewedList.isNotEmpty;

    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (hasPending) ...[
            const SizedBox(height: 12),
            Text(
              'Unreviewed',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 8),
            ...pendingList.map((item) => _buildDocumentRow(item, icon)),
          ],
          if (hasPending && hasReviewed) const SizedBox(height: 16),
          if (hasReviewed) ...[
            const SizedBox(height: 8),
            Text(
              'Reviewed',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            ...reviewedList.map((item) => _buildDocumentRow(item, icon)),
          ],
          if (!hasPending && !hasReviewed)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'No documents uploaded.',
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(_DocumentItem item, IconData icon) {
    final opening = _openingPdf[item.key] == true;
    final isPending = item.onApprove != null;

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
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  isPending ? 'Pending' : 'Approved',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPending ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: opening ? null : item.onView,
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
          if (item.onApprove != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: item.onApprove,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              child: const Text('Approve'),
            ),
          ],
          if (item.onReject != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: item.onReject,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              child: const Text('Reject'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentItem {
  final String key;
  final String title;
  final VoidCallback onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _DocumentItem({
    required this.key,
    required this.title,
    required this.onView,
    this.onApprove,
    this.onReject,
  });
}

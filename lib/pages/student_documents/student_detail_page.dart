import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/api/chat.dart';
import 'package:internship_management_system/api/indemnity_letter.dart';
import 'package:internship_management_system/api/offer_letter.dart';
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/api/placement_agreement.dart';
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/models/application.dart';
import 'package:internship_management_system/models/indemnity_letter.dart';
import 'package:internship_management_system/models/opportunity.dart';
import 'package:internship_management_system/models/placement_agreement.dart';
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
  IndemnityLetterData? _indemnityLetter;
  PlacementAgreementData? _placementAgreement;
  List<Application> _applications = [];
  final Map<int, Opportunity> _opportunities = {};
  bool _loading = true;
  final Map<String, bool> _openingPdf = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    Student? student;
    try {
      final students = await getMentorStudents();
      student = students.cast<Student?>().firstWhere(
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
      IndemnityLetterData? indemnityLetter;
      PlacementAgreementData? placementAgreement;

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
        try {
          indemnityLetter = await getIndemnityLetterByStudent(student.studentId);
        } catch (_) {}
        try {
          placementAgreement = await getPlacementAgreementByStudent(student.studentId);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _student = student;
          _company = company;
          _resumes = resumes;
          _offerLetters = offerLetters;
          _indemnityLetter = indemnityLetter;
          _placementAgreement = placementAgreement;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }

    try {
      if (student != null) {
        final apps = await getStudentApplications(widget.studentId);
        final opps = <int, Opportunity>{};
        for (final app in apps) {
          if (!app.isExternal && app.opportunityId != null) {
            try {
              opps[app.opportunityId!] = await getOpportunity(app.opportunityId!);
            } catch (_) {}
          }
        }
        if (mounted) {
          setState(() {
            _applications = apps;
            _opportunities..clear()..addAll(opps);
          });
        }
      }
    } catch (_) {}
  }

  String _statusFromProgress(String progress) {
    switch (progress) {
      case 'none':
        return 'No Resume';
      case 'resume':
        return 'Resume';
      case 'application':
        return 'Application';
      case 'offer_letter':
        return 'Offer Letter';
      case 'pending_documents':
        return 'Pending Documents';
      case 'accepted':
        return 'Accepted';
      default:
        return progress;
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

  Future<void> _viewIndemnityLetter() async {
    if (_indemnityLetter == null) return;
    final key = 'indemnity:${_indemnityLetter!.indemnityLetterId}';
    setState(() => _openingPdf[key] = true);
    try {
      final bytes = await downloadIndemnityLetter(_indemnityLetter!.indemnityLetterId);
      openPdfInBrowser(bytes, fileName: 'indemnity_letter.pdf');
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

  Future<void> _viewPlacementAgreement() async {
    if (_placementAgreement == null) return;
    final key = 'placement:${_placementAgreement!.placementAgreementId}';
    setState(() => _openingPdf[key] = true);
    try {
      final bytes = await downloadPlacementAgreement(_placementAgreement!.placementAgreementId);
      openPdfInBrowser(bytes, fileName: 'placement_agreement.pdf');
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

  Future<void> _approveIndemnityLetter() async {
    if (_indemnityLetter == null) return;
    try {
      await approveIndemnityLetter(_indemnityLetter!.indemnityLetterId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indemnity letter approved'), backgroundColor: Color(0xFF2E7D32)),
        );
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _approvePlacementAgreement() async {
    if (_placementAgreement == null) return;
    try {
      await approvePlacementAgreement(_placementAgreement!.placementAgreementId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placement agreement approved'), backgroundColor: Color(0xFF2E7D32)),
        );
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
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
                      _buildApplicationsSection(),
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
    final progress = student.progress;
    final status = _statusFromProgress(progress);

    Color statusBg;
    Color statusFg;
    if (progress == 'resume' || progress == 'offer_letter' || progress == 'pending_documents') {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final conversationId = await createOrGetConversation(student.user.userId);
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
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
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
    final hasIndemnity = _indemnityLetter != null;
    final hasPlacement = _placementAgreement != null;

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
        if (!hasResumes && !hasOfferLetters && !hasIndemnity && !hasPlacement)
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
          if (hasResumes && (hasOfferLetters || hasIndemnity || hasPlacement)) const SizedBox(height: 20),
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
          if (hasOfferLetters && (hasIndemnity || hasPlacement)) const SizedBox(height: 20),
          if (hasIndemnity) _buildTypeSection(
            title: 'Indemnity Letter',
            icon: Icons.security_outlined,
            pendingList: !_indemnityLetter!.verified ? [
              _DocumentItem(
                key: 'indemnity:${_indemnityLetter!.indemnityLetterId}',
                title: 'Indemnity Letter',
                onView: () => _viewIndemnityLetter(),
                onApprove: () => _approveIndemnityLetter(),
              ),
            ] : [],
            reviewedList: _indemnityLetter!.verified ? [
              _DocumentItem(
                key: 'indemnity:${_indemnityLetter!.indemnityLetterId}',
                title: 'Indemnity Letter',
                onView: () => _viewIndemnityLetter(),
              ),
            ] : [],
          ),
          if (hasIndemnity && hasPlacement) const SizedBox(height: 20),
          if (hasPlacement) _buildTypeSection(
            title: 'Placement Agreement',
            icon: Icons.assignment_outlined,
            pendingList: !_placementAgreement!.verified ? [
              _DocumentItem(
                key: 'placement:${_placementAgreement!.placementAgreementId}',
                title: 'Placement Agreement',
                onView: () => _viewPlacementAgreement(),
                onApprove: () => _approvePlacementAgreement(),
              ),
            ] : [],
            reviewedList: _placementAgreement!.verified ? [
              _DocumentItem(
                key: 'placement:${_placementAgreement!.placementAgreementId}',
                title: 'Placement Agreement',
                onView: () => _viewPlacementAgreement(),
              ),
            ] : [],
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
  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return const Color(0xFF2E7D32);
      case 'rejected': return const Color(0xFFC62828);
      case 'interview': return const Color(0xFFE65100);
      case 'uploaded': return const Color(0xFFFF8F00);
      default: return const Color(0xFF9E9E9E);
    }
  }

  Widget _buildApplicationsSection() {
    if (_applications.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Applications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: _applications.map((app) {
              final opp = !app.isExternal ? _opportunities[app.opportunityId] : null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                      Icon(
                        app.isExternal ? Icons.business : Icons.work_outline,
                        color: const Color(0xFF717182),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.isExternal
                                  ? (app.jobTitle ?? 'External Application')
                                  : (opp?.title ?? 'Opportunity #${app.opportunityId}'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.isExternal
                                  ? (app.companyName ?? '')
                                  : (opp?.company ?? ''),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF717182),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(app.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          app.status[0].toUpperCase() + app.status.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(app.status),
                          ),
                        ),
                      ),
                      if (app.isExternal) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'External',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
          ),
        ),
      ],
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

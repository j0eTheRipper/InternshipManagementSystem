import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/resume.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/open_pdf.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthState.isStudent
        ? const _StudentResumeView()
        : const _MentorResumeView();
  }
}

class _StudentResumeView extends StatefulWidget {
  const _StudentResumeView();

  @override
  State<_StudentResumeView> createState() => _StudentResumeViewState();
}

class _StudentResumeViewState extends State<_StudentResumeView> {
  List<ResumeData>? _resumes;
  bool _loading = true;
  bool _uploading = false;
  bool _openingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadResume();
  }

  Future<void> _loadResume() async {
    setState(() => _loading = true);
    try {
      _resumes = await getResume();
    } catch (_) {
      _resumes = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickAndUpload() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read file data'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _uploading = true);

      await uploadResume(
        file.bytes!,
        fileName: file.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume uploaded successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      await _loadResume();
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
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _viewPdf(ResumeData resume) async {
    setState(() => _openingPdf = true);
    try {
      final bytes = await downloadResume(resume.resumeId);
      openPdfInBrowser(bytes, fileName: 'resume_${resume.resumeId}.pdf');
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
    if (mounted) setState(() => _openingPdf = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Resume',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              _buildStudentContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentContent() {
    final hasResume = _resumes != null && _resumes!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UploadCard(
          uploading: _uploading,
          hasExisting: hasResume,
          onUpload: _pickAndUpload,
        ),
        if (hasResume) ...[
          const SizedBox(height: 24),
          const Text(
            'Upload History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ..._resumes!.reversed.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ResumeListTile(
              resume: r,
              opening: _openingPdf,
              onView: () => _viewPdf(r),
            ),
          )),
        ],
      ],
    );
  }
}

class _ResumeListTile extends StatelessWidget {
  final ResumeData resume;
  final bool opening;
  final VoidCallback onView;

  const _ResumeListTile({
    required this.resume,
    required this.opening,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = resume.verified;
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.hourglass_empty,
              color: isVerified
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 2),
                Text(
                  isVerified ? 'Approved' : 'Pending',
                  style: TextStyle(
                    fontSize: 13,
                    color: isVerified
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: OutlinedButton.icon(
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
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final bool uploading;
  final bool hasExisting;
  final VoidCallback onUpload;

  const _UploadCard({
    required this.uploading,
    required this.hasExisting,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          Icon(
            Icons.upload_file,
            size: 40,
            color: const Color(0xFF030213).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            hasExisting
                ? 'Upload a new version'
                : 'Upload your resume (PDF only, max 5MB)',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF717182),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: FilledButton.icon(
              onPressed: uploading ? null : onUpload,
              icon: uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 20),
              label: Text(uploading ? 'Uploading...' : 'Select PDF'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorResumeView extends StatefulWidget {
  const _MentorResumeView();

  @override
  State<_MentorResumeView> createState() => _MentorResumeViewState();
}

class _MentorResumeViewState extends State<_MentorResumeView> {
  List<Student>? _students;
  Map<String, List<ResumeData>> _resumeCache = {};
  bool _loading = true;
  String? _expandedStudentId;
  final Map<String, bool> _openingPdf = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    try {
      final students = await getMentorStudents();
      _resumeCache = {};
      for (final s in students) {
        try {
          _resumeCache[s.studentId] = await getResume(studentId: s.studentId);
        } catch (_) {
          _resumeCache[s.studentId] = [];
        }
      }
      if (mounted) {
        setState(() {
          _students = students;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _viewPdf(String studentId, int resumeId) async {
    setState(() => _openingPdf['$studentId:$resumeId'] = true);
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
    if (mounted) setState(() => _openingPdf['$studentId:$resumeId'] = false);
  }

  Future<void> _approveResume(int resumeId, String studentId) async {
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
      await _loadStudents();
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Resumes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review and approve your students\' resumes',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_students == null || _students!.isEmpty)
              _buildEmpty()
            else
              ..._students!.map((s) => _buildStudentCard(s)),
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
          'No students assigned to you',
          style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final resumes = _resumeCache[student.studentId] ?? [];
    final latest = resumes.isNotEmpty ? resumes.last : null;
    final isExpanded = _expandedStudentId == student.studentId;

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
                  _expandedStudentId =
                      isExpanded ? null : student.studentId;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFF5F5F5),
                      child: Text(
                        student.user.fullname.isNotEmpty
                            ? student.user.fullname[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 16,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student.fieldOfStudy} · Year ${student.yearOfStudy}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF717182),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      hasResume: latest != null,
                      isVerified: latest?.verified ?? false,
                    ),
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
                    if (resumes.isEmpty)
                      const Text(
                        'No resume uploaded yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                      )
                    else
                      ...resumes.reversed.map(
                        (r) => _buildResumeRow(r, student.studentId),
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

  Widget _buildResumeRow(ResumeData resume, String studentId) {
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
            onPressed: _openingPdf['$studentId:${resume.resumeId}'] == true
                ? null
                : () => _viewPdf(studentId, resume.resumeId),
            icon: _openingPdf['$studentId:${resume.resumeId}'] == true
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.visibility_outlined, size: 16),
            label: Text(
              _openingPdf['$studentId:${resume.resumeId}'] == true
                  ? 'Opening...'
                  : 'View',
            ),
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
          if (!resume.verified) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _approveResume(resume.resumeId, studentId),
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

class _StatusBadge extends StatelessWidget {
  final bool hasResume;
  final bool isVerified;

  const _StatusBadge({required this.hasResume, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    if (!hasResume) {
      label = 'No Resume';
      bg = const Color(0xFFF5F5F5);
      fg = const Color(0xFF9E9E9E);
    } else if (isVerified) {
      label = 'Approved';
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    } else {
      label = 'Pending';
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

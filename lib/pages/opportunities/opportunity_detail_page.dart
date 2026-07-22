import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/api/offer_letter.dart' as ol;
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/opportunity.dart';
import 'package:internship_management_system/models/resume.dart';
import 'package:internship_management_system/open_pdf.dart';

class OpportunityDetailPage extends StatefulWidget {
  final int opportunityId;

  const OpportunityDetailPage({super.key, required this.opportunityId});

  @override
  State<OpportunityDetailPage> createState() => _OpportunityDetailPageState();
}

class _OpportunityDetailPageState extends State<OpportunityDetailPage> {
  Opportunity? _opportunity;
  bool _loading = true;
  String? _error;
  bool _applying = false;
  bool _alreadyApplied = false;
  ResumeData? _appliedResume;
  dynamic _matchedApplication;
  bool _openingPdf = false;
  bool _uploadingOfferLetter = false;
  Map<String, dynamic>? _offerLetter;
  bool _downloadingOfferLetter = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        getOpportunity(widget.opportunityId),
        getMyApplications(),
      ]);
      _opportunity = results[0] as Opportunity;
      final apps = results[1] as List;
      final match = apps.where((a) => a.opportunityId == widget.opportunityId);
      if (match.isNotEmpty) {
        _alreadyApplied = true;
        final app = match.first;
        _matchedApplication = app;
        final resumes = await getResume();
        final matched = resumes.where((r) => r.resumeId == app.resumeId);
        if (matched.isNotEmpty) {
          _appliedResume = matched.first;
        }
        try {
          _offerLetter = await ol.getOfferLetterByApplication(app.applicationId);
        } catch (_) {
          _offerLetter = null;
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _apply() async {
    setState(() => _applying = true);
    try {
      final resumes = await getResume();
      if (resumes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload a resume first')),
          );
        }
        return;
      }

      if (!mounted) return;
      final selected = await showDialog<ResumeData>(
        context: context,
        builder: (ctx) => _ResumePickerDialog(resumes: resumes),
      );

      if (selected == null) return;

      await apply(opportunityId: widget.opportunityId, resumeId: selected.resumeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted!')),
        );
        context.go('/my-applications');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _viewAppliedPdf() async {
    if (_appliedResume == null || _openingPdf) return;
    setState(() => _openingPdf = true);
    try {
      final bytes = await downloadResume(_appliedResume!.resumeId);
      openPdfInBrowser(bytes, fileName: 'resume_${_appliedResume!.resumeId}.pdf');
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

  Future<void> _uploadOfferLetter() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null) return;

    final file = result.files.single;
    if (file.bytes == null) return;

    if (file.bytes!.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File exceeds 5MB limit'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _uploadingOfferLetter = true);
    try {
      await ol.uploadOfferLetter(
        applicationId: _matchedApplication.applicationId,
        fileBytes: file.bytes!,
        fileName: file.name,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer letter uploaded!')),
        );
        _fetch();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingOfferLetter = false);
    }
  }

  Future<void> _viewOfferLetterPdf() async {
    if (_offerLetter == null || _downloadingOfferLetter) return;
    setState(() => _downloadingOfferLetter = true);
    try {
      final bytes = await ol.downloadOfferLetter(_offerLetter!['offer_letter_id'] as int);
      openPdfInBrowser(bytes, fileName: 'offer_letter_${_offerLetter!['offer_letter_id']}.pdf');
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
    if (mounted) setState(() => _downloadingOfferLetter = false);
  }

  Widget _buildOfferLetterStatus() {
    final status = _matchedApplication.status as String;
    switch (status) {
      case 'pending':
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _uploadingOfferLetter ? null : _uploadOfferLetter,
            icon: _uploadingOfferLetter
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Offer Letter'),
          ),
        );
      case 'uploaded':
        return InkWell(
          onTap: _viewOfferLetterPdf,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 18, color: Color(0xFF717182)),
                const SizedBox(width: 8),
                Text(
                  'Offer Letter',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Awaiting review',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _downloadingOfferLetter ? Icons.hourglass_top : Icons.open_in_new,
                  size: 16,
                  color: const Color(0xFF717182),
                ),
              ],
            ),
          ),
        );
      case 'accepted':
        return const Row(
          children: [
            Icon(Icons.verified, size: 18, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text(
              'Offer letter approved',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
            ),
          ],
        );
      case 'rejected':
        return const Row(
          children: [
            Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFC62828)),
            SizedBox(width: 8),
            Text(
              'Offer letter rejected',
              style: TextStyle(fontSize: 14, color: Color(0xFFC62828)),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _opportunity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Opportunity')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Not found', style: const TextStyle(color: Colors.red)),
              TextButton(onPressed: _fetch, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final opp = _opportunity!;
    return Scaffold(
      appBar: AppBar(title: Text(opp.title)),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: RefreshIndicator(
          onRefresh: _fetch,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '${opp.company} · ${opp.jobRole}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF717182)),
            ),
            if (opp.fieldOfStudy.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                opp.fieldOfStudy,
                style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              opp.location,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: opp.status == 'remote'
                    ? const Color(0xFFE8F5E9)
                    : opp.status == 'hybrid'
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opp.status[0].toUpperCase() + opp.status.substring(1),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: opp.status == 'remote'
                      ? const Color(0xFF2E7D32)
                      : opp.status == 'hybrid'
                          ? const Color(0xFFE65100)
                          : const Color(0xFF1565C0),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              opp.description,
              style: const TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.5),
            ),
            if (AuthState.isStudent && !_alreadyApplied) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _applying ? null : _apply,
                  child: _applying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Apply Now', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
            if (_alreadyApplied)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outlined, size: 20, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text(
                            'You have already applied',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                      if (_appliedResume != null) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _viewAppliedPdf,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.description_outlined, size: 18, color: Color(0xFF717182)),
                                const SizedBox(width: 8),
                                Text(
                                  'Resume #${_appliedResume!.resumeId}',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _appliedResume!.verified
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _appliedResume!.verified ? 'Verified' : 'Not verified',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _appliedResume!.verified
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE65100),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _openingPdf ? Icons.hourglass_top : Icons.open_in_new,
                                  size: 16,
                                  color: const Color(0xFF717182),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_matchedApplication != null) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        _buildOfferLetterStatus(),
                      ],
                    ],
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}

class _ResumePickerDialog extends StatelessWidget {
  final List<ResumeData> resumes;

  const _ResumePickerDialog({required this.resumes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a resume'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: resumes.length,
          itemBuilder: (context, index) {
            final resume = resumes[index];
            return RadioGroup<int>(
              onChanged: (value) {
                Navigator.pop(context, resume);
              },
              child: RadioListTile<int>(
                title: Text('Resume #${resume.resumeId}'),
                subtitle: Text(resume.verified ? 'Verified' : 'Not verified'),
                value: resume.resumeId,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

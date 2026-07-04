import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/api/offer_letter.dart' as ol;
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/models/application.dart';
import 'package:internship_management_system/models/resume.dart';
import 'package:internship_management_system/open_pdf.dart';

class ExternalApplicationDetailPage extends StatefulWidget {
  final int applicationId;

  const ExternalApplicationDetailPage({super.key, required this.applicationId});

  @override
  State<ExternalApplicationDetailPage> createState() => _ExternalApplicationDetailPageState();
}

class _ExternalApplicationDetailPageState extends State<ExternalApplicationDetailPage> {
  Application? _application;
  bool _loading = true;
  String? _error;
  Uint8List? _screenshotBytes;
  bool _screenshotLoading = false;
  ResumeData? _appliedResume;
  Map<String, dynamic>? _offerLetter;
  bool _uploadingOfferLetter = false;
  bool _downloadingOfferLetter = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final app = await getApplication(widget.applicationId);
      _application = app;

      if (app.applicationScreenshot != null) {
        _loadScreenshot();
      }

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
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _loadScreenshot() async {
    setState(() => _screenshotLoading = true);
    try {
      final bytes = await downloadScreenshot(widget.applicationId);
      if (mounted) setState(() => _screenshotBytes = bytes);
    } catch (_) {
      // screenshot failed to load, show placeholder
    }
    if (mounted) setState(() => _screenshotLoading = false);
  }

  Future<void> _viewResumePdf() async {
    if (_appliedResume == null) return;
    try {
      final bytes = await downloadResume(_appliedResume!.resumeId);
      openPdfInBrowser(bytes, fileName: 'resume_${_appliedResume!.resumeId}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
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
          const SnackBar(content: Text('File exceeds 5MB limit'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _uploadingOfferLetter = true);
    try {
      await ol.uploadOfferLetter(
        applicationId: widget.applicationId,
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
    if (mounted) setState(() => _downloadingOfferLetter = false);
  }

  void _showFullScreenImage() {
    if (_screenshotBytes == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.memory(_screenshotBytes!, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return const Color(0xFF2E7D32);
      case 'rejected': return const Color(0xFFC62828);
      case 'interview': return const Color(0xFFE65100);
      default: return const Color(0xFF9E9E9E);
    }
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'remote': return const Color(0xFF2E7D32);
      case 'hybrid': return const Color(0xFFE65100);
      case 'on-site': return const Color(0xFF1565C0);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_application?.companyName ?? 'External Application')),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_application == null) {
      return const Center(child: Text('Application not found'));
    }

    final app = _application!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          app.companyName ?? 'Unknown Company',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 4),
        Text(
          app.jobTitle ?? '',
          style: const TextStyle(fontSize: 16, color: Color(0xFF717182)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _modeColor(app.jobMode ?? '').withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                (app.jobMode ?? 'remote')[0].toUpperCase() + (app.jobMode ?? 'remote').substring(1),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _modeColor(app.jobMode ?? '')),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              app.companyLocation ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(app.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            app.status[0].toUpperCase() + app.status.substring(1),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor(app.status)),
          ),
        ),

        const SizedBox(height: 24),

        if (_screenshotLoading || _screenshotBytes != null) ...[
          const Text('Screenshot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          if (_screenshotLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          else
            InkWell(
              onTap: _showFullScreenImage,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_screenshotBytes!, fit: BoxFit.cover, height: 300, width: double.infinity),
              ),
            ),
          const SizedBox(height: 24),
        ],

        if (_appliedResume != null) ...[
          const Text('Resume Used', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          InkWell(
            onTap: _viewResumePdf,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 20, color: Color(0xFF717182)),
                  const SizedBox(width: 12),
                  Text('Resume #${_appliedResume!.resumeId}', style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _appliedResume!.verified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _appliedResume!.verified ? 'Verified' : 'Not verified',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _appliedResume!.verified ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.open_in_new, size: 16, color: Color(0xFF717182)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (app.opportunityId == null) ...[
          const Text('Offer Letter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          _buildOfferLetterStatus(),
        ],
      ],
    );
  }

  Widget _buildOfferLetterStatus() {
    final status = _application?.status ?? 'pending';
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
}

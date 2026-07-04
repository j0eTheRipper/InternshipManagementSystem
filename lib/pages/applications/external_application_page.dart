import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/models/resume.dart';

class ExternalApplicationPage extends StatefulWidget {
  const ExternalApplicationPage({super.key});

  @override
  State<ExternalApplicationPage> createState() => _ExternalApplicationPageState();
}

class _ExternalApplicationPageState extends State<ExternalApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _jobMode = 'remote';
  ResumeData? _selectedResume;
  List<ResumeData> _resumes = [];
  Uint8List? _screenshotBytes;
  String? _screenshotName;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _jobTitleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadResumes() async {
    try {
      final resumes = await getResume();
      if (mounted) {
        setState(() {
          _resumes = resumes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load resumes: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _pickScreenshot() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'],
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

    setState(() {
      _screenshotBytes = file.bytes;
      _screenshotName = file.name;
    });
  }

  Future<void> _pickResume() async {
    if (_resumes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No resumes available. Upload a resume first.')),
      );
      return;
    }

    final selected = await showDialog<ResumeData>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select a resume'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _resumes.length,
            itemBuilder: (context, index) {
              final resume = _resumes[index];
              return ListTile(
                title: Text('Resume #${resume.resumeId}'),
                subtitle: Text(resume.verified ? 'Verified' : 'Not verified'),
                trailing: resume.verified
                    ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20)
                    : const Icon(Icons.hourglass_empty, color: Color(0xFFE65100), size: 20),
                onTap: () => Navigator.pop(ctx, resume),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );

    if (selected != null) {
      setState(() => _selectedResume = selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_screenshotBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a screenshot'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await createExternalApplication(
        companyName: _companyNameCtrl.text.trim(),
        jobTitle: _jobTitleCtrl.text.trim(),
        jobMode: _jobMode,
        companyLocation: _locationCtrl.text.trim(),
        resumeId: _selectedResume!.resumeId,
        screenshotBytes: _screenshotBytes!,
        screenshotFileName: _screenshotName ?? 'screenshot.png',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('External application recorded!')),
        );
        context.go('/my-applications');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('External Application')),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _companyNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Company Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _jobTitleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Job Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _jobMode,
                          decoration: const InputDecoration(
                            labelText: 'Job Mode',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'remote', child: Text('Remote')),
                            DropdownMenuItem(value: 'on-site', child: Text('On-site')),
                            DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _jobMode = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Company Location',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Resume Used',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickResume,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedResume != null ? Icons.description : Icons.add_circle_outline,
                                  size: 20,
                                  color: const Color(0xFF717182),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedResume != null
                                        ? 'Resume #${_selectedResume!.resumeId}${_selectedResume!.verified ? '' : ' (not verified)'}'
                                        : 'Tap to select a resume',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedResume != null ? const Color(0xFF1A1A1A) : const Color(0xFF717182),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Application Screenshot',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickScreenshot,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.image, size: 20, color: Color(0xFF717182)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _screenshotName ?? 'Tap to upload screenshot (image only)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _screenshotName != null ? const Color(0xFF1A1A1A) : const Color(0xFF717182),
                                    ),
                                  ),
                                ),
                                if (_screenshotBytes != null)
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE0E0E0)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.memory(_screenshotBytes!, fit: BoxFit.cover),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Submit External Application', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

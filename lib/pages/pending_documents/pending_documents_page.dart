import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:internship_management_system/api/indemnity_letter.dart';
import 'package:internship_management_system/api/placement_agreement.dart';
import 'package:internship_management_system/api/student.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/indemnity_letter.dart';
import 'package:internship_management_system/models/placement_agreement.dart';

class PendingDocumentsPage extends StatefulWidget {
  const PendingDocumentsPage({super.key});

  @override
  State<PendingDocumentsPage> createState() => _PendingDocumentsPageState();
}

class _PendingDocumentsPageState extends State<PendingDocumentsPage> {
  bool _loading = true;
  int _currentStep = 0;

  DateTime? _startDate;
  int _durationWeeks = 12;
  bool _datesSaved = false;

  IndemnityLetterData? _indemnityLetter;
  bool _indemnityUploading = false;

  PlacementAgreementData? _placementAgreement;
  bool _placementUploading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _supervisorSaved = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final student = AuthState.currentStudent;
    if (student == null) return;

    if (student.internshipStartDate != null) {
      _startDate = DateTime.tryParse(student.internshipStartDate!);
      _durationWeeks = student.internshipDurationWeeks ?? 12;
      _datesSaved = true;
    }

    if (student.companySupervisorName != null) {
      _nameController.text = student.companySupervisorName!;
      _supervisorSaved = true;
    }
    if (student.companySupervisorEmail != null) {
      _emailController.text = student.companySupervisorEmail!;
    }
    if (student.companySupervisorPhone != null) {
      _phoneController.text = student.companySupervisorPhone!;
    }

    try {
      _indemnityLetter = await getIndemnityLetterByStudent(student.studentId);
    } catch (_) {}

    try {
      _placementAgreement = await getPlacementAgreementByStudent(student.studentId);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _loading = false;
        _currentStep = _calculateStep();
      });
    }
  }

  int _calculateStep() {
    if (!_datesSaved) return 0;
    if (_indemnityLetter == null) return 1;
    if (_placementAgreement == null) return 2;
    if (!_supervisorSaved) return 3;
    return 4;
  }

  bool _isStepComplete(int step) {
    switch (step) {
      case 0: return _datesSaved;
      case 1: return _indemnityLetter != null;
      case 2: return _placementAgreement != null;
      case 3: return _supervisorSaved;
      default: return false;
    }
  }

  Future<void> _saveDates() async {
    if (_startDate == null) return;
    final formatted =
        '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
    await updateInternshipDetails(startDate: formatted, durationWeeks: _durationWeeks);
    final userId = AuthState.currentUser?.userId;
    if (userId != null) {
      final updated = await getStudent(userId.toString());
      AuthState.updateStudentData(updated);
    }
    setState(() {
      _datesSaved = true;
      _currentStep = _calculateStep();
    });
  }

  Future<void> _uploadIndemnity() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _indemnityUploading = true);
    try {
      await uploadIndemnityLetter(fileBytes: file.bytes!, fileName: file.name);
      final student = AuthState.currentStudent;
      if (student != null) {
        _indemnityLetter = await getIndemnityLetterByStudent(student.studentId);
      }
      setState(() {
        _indemnityUploading = false;
        _currentStep = _calculateStep();
      });
    } catch (e) {
      setState(() => _indemnityUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _uploadPlacement() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _placementUploading = true);
    try {
      await uploadPlacementAgreement(fileBytes: file.bytes!, fileName: file.name);
      final student = AuthState.currentStudent;
      if (student != null) {
        _placementAgreement = await getPlacementAgreementByStudent(student.studentId);
      }
      setState(() {
        _placementUploading = false;
        _currentStep = _calculateStep();
      });
    } catch (e) {
      setState(() => _placementUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _saveSupervisorDetails() async {
    await submitSupervisorDetails(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    final userId = AuthState.currentUser?.userId;
    if (userId != null) {
      final updated = await getStudent(userId.toString());
      AuthState.updateStudentData(updated);
    }
    setState(() {
      _supervisorSaved = true;
      _currentStep = _calculateStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final allDone = _currentStep == 4;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Your Setup',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete the following steps before your mentor verifies your documents.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 28),
                _buildStepIndicator(),
                const SizedBox(height: 24),
                if (allDone) _buildWaitingCard() else _buildCurrentStepContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      ('Internship Dates', Icons.calendar_today),
      ('Indemnity Letter', Icons.description_outlined),
      ('Placement Agreement', Icons.article_outlined),
      ('Supervisor Details', Icons.person_outline),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final (label, icon) = steps[i];
          final complete = _isStepComplete(i);
          final active = i == _currentStep && !allDone;

          return Padding(
            padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 16 : 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: complete
                        ? const Color(0xFF2E7D32)
                        : active
                            ? const Color(0xFF030213)
                            : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: complete
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Icon(icon, size: 16, color: active ? Colors.white : const Color(0xFF9E9E9E)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: complete
                          ? const Color(0xFF2E7D32)
                          : active
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
                if (complete)
                  const Icon(Icons.check_circle, size: 18, color: Color(0xFF2E7D32)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildDatesStep();
      case 1: return _buildIndemnityStep();
      case 2: return _buildPlacementStep();
      case 3: return _buildSupervisorStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildDatesStep() {
    return _buildCard(
      title: 'Internship Dates',
      subtitle: 'Select your internship start date and duration.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Start date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _startDate = picked);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFF717182)),
                  const SizedBox(width: 12),
                  Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: _startDate != null ? const Color(0xFF1A1A1A) : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Duration (weeks)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _durationWeeks > 1 ? () => setState(() => _durationWeeks--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF030213),
              ),
              const SizedBox(width: 12),
              Text(
                '$_durationWeeks',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _durationWeeks < 52 ? () => setState(() => _durationWeeks++) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF030213),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButton('Save Dates', _startDate != null, _saveDates),
        ],
      ),
    );
  }

  Widget _buildIndemnityStep() {
    return _buildCard(
      title: 'Indemnity Letter',
      subtitle: 'Upload your indemnity letter as a PDF.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_indemnityLetter != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Indemnity letter uploaded', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2E7D32))),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _indemnityUploading ? null : _uploadIndemnity,
                icon: _indemnityUploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file, size: 18),
                label: Text(_indemnityUploading ? 'Uploading...' : 'Choose PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlacementStep() {
    return _buildCard(
      title: 'Placement Agreement',
      subtitle: 'Upload your placement agreement form as a PDF.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_placementAgreement != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Placement agreement uploaded', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2E7D32))),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _placementUploading ? null : _uploadPlacement,
                icon: _placementUploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file, size: 18),
                label: Text(_placementUploading ? 'Uploading...' : 'Choose PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupervisorStep() {
    return _buildCard(
      title: 'Company Supervisor Details',
      subtitle: 'Provide your company supervisor\'s contact information.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Full Name', _nameController),
          const SizedBox(height: 16),
          _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          _buildActionButton(
            'Save Details',
            _nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _phoneController.text.isNotEmpty,
            _saveSupervisorDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_top_rounded, size: 48, color: const Color(0xFF757575).withValues(alpha: 0.6)),
          const SizedBox(height: 20),
          const Text(
            'Waiting for Verification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your documents have been submitted. Your mentor will review them shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Enter $label'.toLowerCase(),
            hintStyle: const TextStyle(color: Color(0xFFABABAB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF030213)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, bool enabled, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF030213),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  bool get allDone => _currentStep == 4;
}

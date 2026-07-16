import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/admin.dart';
import 'package:internship_management_system/models/user.dart';

class AdminAddStudentForm extends StatefulWidget {
  const AdminAddStudentForm({super.key});

  @override
  State<AdminAddStudentForm> createState() => _AdminAddStudentFormState();
}

class _AdminAddStudentFormState extends State<AdminAddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _yearController = TextEditingController();

  List<User> _mentors = [];
  List<String> _programmes = [];
  bool _loadingMentors = true;
  bool _submitting = false;
  int? _selectedMentorId;
  String? _selectedProgramme;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        getAllMentors(),
        rootBundle.loadString('assets/ungerGradProgrammes.json'),
      ]);
      final mentors = results[0] as List<User>;
      final programmes = (jsonDecode(results[1] as String) as List).cast<String>();
      programmes.sort();
      if (mounted) {
        setState(() {
          _mentors = mentors;
          _programmes = programmes;
          _loadingMentors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMentors = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A1A1A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await createStudent(
        fullname: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        studentId: _studentIdController.text.trim(),
        yearOfStudy: int.parse(_yearController.text.trim()),
        fieldOfStudy: _selectedProgramme!,
        mentorId: _selectedMentorId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student created'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        context.go('/admin/students');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
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
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/admin/students'),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Add Student',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a new student account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717182),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                ),
              ),
              child: _loadingMentors
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mentor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedMentorId,
                            decoration: _inputDecoration('Select a mentor'),
                            items: _mentors
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m.userId,
                                    child: Text(m.fullname),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedMentorId = value);
                            },
                            validator: (v) =>
                                v == null ? 'Mentor is required' : null,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('Enter full name'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('Enter email'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Student ID',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _studentIdController,
                            decoration: _inputDecoration('e.g. TP0112233'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Student ID is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration:
                                _inputDecoration('Enter password (min 6 characters)'),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Year of Study',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Enter year of study'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Year of study is required';
                              }
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 1 || n > 10) {
                                return 'Must be a number between 1 and 10';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Field of Study',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProgramme,
                            isExpanded: true,
                            decoration: _inputDecoration('Select a programme'),
                            items: _programmes
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedProgramme = value);
                            },
                            validator: (v) =>
                                v == null ? 'Field of study is required' : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A1A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Create Student',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

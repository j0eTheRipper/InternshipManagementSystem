import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/api/admin.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/config.dart';

class AdminCompanySupervisorsPage extends StatefulWidget {
  const AdminCompanySupervisorsPage({super.key});

  @override
  State<AdminCompanySupervisorsPage> createState() => _AdminCompanySupervisorsPageState();
}

class _AdminCompanySupervisorsPageState extends State<AdminCompanySupervisorsPage> {
  List<Map<String, dynamic>> _supervisors = [];
  List<Map<String, dynamic>> _pendingSupervisors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _fetchSupervisorsRaw(),
        getPendingSupervisors(),
      ]);
      if (mounted) {
        setState(() {
          _supervisors = results[0] as List<Map<String, dynamic>>;
          _pendingSupervisors = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSupervisorsRaw() async {
    final token = AuthState.token;
    final response = await http.get(
      Uri.parse('$baseUrl/admin/company-supervisors'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    AuthState.requireAuth(response);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> _deleteSupervisor(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete supervisor'),
        content: const Text('Are you sure you want to delete this company supervisor?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final token = AuthState.token;
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/company-supervisors/$userId'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      AuthState.requireAuth(response);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supervisor deleted')),
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

  Future<void> _showCreateDialog({String? preName, String? preEmail}) async {
    final nameController = TextEditingController(text: preName ?? '');
    final emailController = TextEditingController(text: preEmail ?? '');
    final passwordController = TextEditingController();
    final companyIdController = TextEditingController(text: '1');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Company Supervisor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: companyIdController,
              decoration: const InputDecoration(labelText: 'Company ID'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = AuthState.token;
      final response = await http.post(
        Uri.parse('$baseUrl/admin/company-supervisors'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullname': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'company_id': int.parse(companyIdController.text),
        }),
      );
      AuthState.requireAuth(response);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supervisor created')),
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
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Company Supervisors',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage company supervisor accounts',
                              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showCreateDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Supervisor'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF030213),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_pendingSupervisors.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3E0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_add_outlined, size: 18, color: Color(0xFFE65100)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Pending Supervisors (${_pendingSupervisors.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Students have submitted these supervisor details but the accounts haven\'t been created yet.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                    ),
                    const SizedBox(height: 12),
                    ...(_pendingSupervisors.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPendingCard(p),
                    ))),
                    const SizedBox(height: 24),
                  ],
                  if (_supervisors.isEmpty && _pendingSupervisors.isEmpty)
                    _buildEmptyState()
                  else if (_supervisors.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        itemCount: _supervisors.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _buildSupervisorCard(_supervisors[index]),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.business_center_outlined, size: 48, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          const Text(
            'No company supervisors',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a company supervisor to get started.',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> pending) {
    final name = pending['name'] as String? ?? '';
    final email = pending['email'] as String? ?? '';
    final phone = pending['phone'] as String? ?? '';

    final initials = name.split(' ').length >= 2
        ? '${name.split(' ')[0][0]}${name.split(' ')[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCreateDialog(preName: name, preEmail: email),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFFF3E0),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20, color: Color(0xFFE65100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupervisorCard(Map<String, dynamic> supervisor) {
    final user = supervisor['user'] as Map<String, dynamic>;
    final company = supervisor['company'] as Map<String, dynamic>;
    final name = user['fullname'] as String? ?? '';
    final email = user['email'] as String? ?? '';
    final companyName = company['name'] as String? ?? '';
    final userId = user['user_id'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF5F5F5),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF030213)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Company: $companyName',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteSupervisor(userId),
            icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFC62828)),
          ),
        ],
      ),
    );
  }
}

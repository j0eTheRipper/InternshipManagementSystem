import 'package:flutter/material.dart';
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/models/opportunity.dart';

class HeadhunterPostingsPage extends StatefulWidget {
  const HeadhunterPostingsPage({super.key});

  @override
  State<HeadhunterPostingsPage> createState() => _HeadhunterPostingsPageState();
}

class _HeadhunterPostingsPageState extends State<HeadhunterPostingsPage> {
  List<Opportunity>? _opportunities;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      _opportunities = await getMyOpportunities();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _delete(int id) async {
    try {
      await deleteOpportunity(id);
      await _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String selectedStatus = 'remote';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post New Opportunity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Job Role')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              const SizedBox(height: 8),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'remote', child: Text('Remote')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'on-site', child: Text('On-site')),
                ],
                onChanged: (v) => selectedStatus = v ?? 'remote',
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty || roleCtrl.text.isEmpty || descCtrl.text.isEmpty || locCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await createOpportunity(
                  title: titleCtrl.text,
                  jobRole: roleCtrl.text,
                  description: descCtrl.text,
                  location: locCtrl.text,
                  status: selectedStatus,
                );
                await _fetch();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
                  );
                }
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Postings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
                FilledButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Posting'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
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
    if (_opportunities == null || _opportunities!.isEmpty) {
      return const Center(
        child: Text(
          'No postings yet. Tap "New Posting" to create one.',
          style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _opportunities!.length,
      itemBuilder: (context, index) {
        final opp = _opportunities![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(opp.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${opp.jobRole} · ${opp.location}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.people_outlined),
                  tooltip: 'View applicants',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ApplicantsPage(opportunityId: opp.opportunityId, opportunityTitle: opp.title),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outlined, color: Colors.red),
                  onPressed: () => _delete(opp.opportunityId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ApplicantsPage extends StatefulWidget {
  final int opportunityId;
  final String opportunityTitle;

  const _ApplicantsPage({required this.opportunityId, required this.opportunityTitle});

  @override
  State<_ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<_ApplicantsPage> {
  List? _applications;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      _applications = (await getApplicants(widget.opportunityId)).map((a) => a as dynamic).toList();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _accept(int appId) async {
    try {
      await acceptApplication(appId);
      await _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _updateStatus(int appId, String status) async {
    try {
      await updateApplicationStatus(appId, status);
      await _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applicants - ${widget.opportunityTitle}')),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_applications == null || _applications!.isEmpty) {
      return const Center(child: Text('No applications yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _applications!.length,
      itemBuilder: (context, index) {
        final app = _applications![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Student: ${app['student_id']}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: app['status'] == 'accepted'
                            ? const Color(0xFFE8F5E9)
                            : app['status'] == 'rejected'
                                ? const Color(0xFFFFEBEE)
                                : app['status'] == 'interview'
                                    ? const Color(0xFFFFF3E0)
                                    : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        app['status'].toString().substring(0, 1).toUpperCase() +
                            app['status'].toString().substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: app['status'] == 'accepted'
                              ? const Color(0xFF2E7D32)
                              : app['status'] == 'rejected'
                                  ? const Color(0xFFC62828)
                                  : app['status'] == 'interview'
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFF757575),
                        ),
                      ),
                    ),
                  ],
                ),
                if (app['status'] == 'pending' || app['status'] == 'interview') ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (app['status'] == 'pending')
                        TextButton(
                          onPressed: () => _updateStatus(app['application_id'], 'interview'),
                          child: const Text('Shortlist'),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _updateStatus(app['application_id'], 'rejected'),
                        child: const Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _accept(app['application_id']),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

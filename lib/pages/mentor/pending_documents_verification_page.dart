import 'package:flutter/material.dart';
import 'package:internship_management_system/api/indemnity_letter.dart';
import 'package:internship_management_system/api/placement_agreement.dart';
import 'package:internship_management_system/open_pdf.dart';

class MentorPendingDocumentsPage extends StatefulWidget {
  const MentorPendingDocumentsPage({super.key});

  @override
  State<MentorPendingDocumentsPage> createState() => _MentorPendingDocumentsPageState();
}

class _MentorPendingDocumentsPageState extends State<MentorPendingDocumentsPage> {
  List<Map<String, dynamic>> _indemnityItems = [];
  List<Map<String, dynamic>> _placementItems = [];
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
      final indemnity = await getPendingIndemnityLetters();
      final placement = await getPendingPlacementAgreements();
      _indemnityItems = indemnity;
      _placementItems = placement;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _viewIndemnity(int id) async {
    try {
      final bytes = await downloadIndemnityLetter(id);
      openPdfInBrowser(bytes, fileName: 'indemnity_letter_$id');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _viewPlacement(int id) async {
    try {
      final bytes = await downloadPlacementAgreement(id);
      openPdfInBrowser(bytes, fileName: 'placement_agreement_$id');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _approveIndemnity(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve indemnity letter'),
        content: const Text('Are you sure you want to approve this indemnity letter?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await approveIndemnityLetter(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indemnity letter approved')),
        );
      }
      _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _approvePlacement(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve placement agreement'),
        content: const Text('Are you sure you want to approve this placement agreement?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await approvePlacementAgreement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placement agreement approved')),
        );
      }
      _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Pending Documents',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            ),
          ),
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

    final hasItems = _indemnityItems.isNotEmpty || _placementItems.isNotEmpty;
    if (!hasItems) {
      return const Center(
        child: Text('No pending documents.', style: TextStyle(fontSize: 16, color: Color(0xFF717182))),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (_indemnityItems.isNotEmpty) ...[
          const Text(
            'Indemnity Letters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          ..._indemnityItems.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['student_name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Indemnity Letter',
                          style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'View file',
                    onPressed: () => _viewIndemnity(item['indemnity_letter_id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 20),
                    tooltip: 'Approve',
                    onPressed: () => _approveIndemnity(item['indemnity_letter_id']),
                  ),
                ],
              ),
            ),
          )),
        ],
        if (_placementItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Placement Agreements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          ..._placementItems.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['student_name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Placement Agreement',
                          style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'View file',
                    onPressed: () => _viewPlacement(item['placement_agreement_id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 20),
                    tooltip: 'Approve',
                    onPressed: () => _approvePlacement(item['placement_agreement_id']),
                  ),
                ],
              ),
            ),
          )),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

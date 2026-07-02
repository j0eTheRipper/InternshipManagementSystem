import 'package:flutter/material.dart';
import 'package:internship_management_system/api/offer_letter.dart';
import 'package:internship_management_system/open_pdf.dart';

class MentorOfferLettersPage extends StatefulWidget {
  const MentorOfferLettersPage({super.key});

  @override
  State<MentorOfferLettersPage> createState() => _MentorOfferLettersPageState();
}

class _MentorOfferLettersPageState extends State<MentorOfferLettersPage> {
  List<Map<String, dynamic>> _items = [];
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
      final raw = await getPendingOfferLetters();
      _items = raw.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _viewFile(int offerLetterId) async {
    try {
      final bytes = await downloadOfferLetter(offerLetterId);
      openPdfInBrowser(bytes, fileName: 'offer_letter_$offerLetterId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _approve(int offerLetterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve offer letter'),
        content: const Text('Are you sure you want to approve this offer letter?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
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
      _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _reject(int offerLetterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject offer letter'),
        content: const Text('Are you sure you want to reject this offer letter?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
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
      _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red.shade700),
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
              'Pending Offer Letters',
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
    if (_items.isEmpty) {
      return const Center(
        child: Text('No pending offer letters.', style: TextStyle(fontSize: 16, color: Color(0xFF717182))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
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
                      Text(
                        item['opportunity_title'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20),
                  tooltip: 'View file',
                  onPressed: () => _viewFile(item['offer_letter_id']),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 20),
                  tooltip: 'Approve',
                  onPressed: () => _approve(item['offer_letter_id']),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFFC62828), size: 20),
                  tooltip: 'Reject',
                  onPressed: () => _reject(item['offer_letter_id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

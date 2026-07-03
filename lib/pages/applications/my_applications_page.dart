import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/application.dart';
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/models/application.dart';
import 'package:internship_management_system/models/opportunity.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<Application>? _applications;
  Map<int, Opportunity> _opportunities = {};
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
      final apps = await getMyApplications();
      _applications = apps;
      for (final app in apps) {
        try {
          _opportunities[app.opportunityId] = await getOpportunity(app.opportunityId);
        } catch (_) {}
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return const Color(0xFF2E7D32);
      case 'rejected': return const Color(0xFFC62828);
      case 'interview': return const Color(0xFFE65100);
      case 'uploaded': return const Color(0xFFFF8F00);
      default: return const Color(0xFF9E9E9E);
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
              'My Applications',
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
    if (_applications == null || _applications!.isEmpty) {
      return const Center(
        child: Text('No applications yet.', style: TextStyle(fontSize: 16, color: Color(0xFF717182))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _applications!.length,
      itemBuilder: (context, index) {
        final app = _applications![index];
        final opp = _opportunities[app.opportunityId];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(opp?.title ?? 'Opportunity #${app.opportunityId}'),
            subtitle: Text('${opp?.company ?? ''} · ${opp?.jobRole ?? ''}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(app.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                app.status[0].toUpperCase() + app.status.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(app.status),
                ),
              ),
            ),
            onTap: () => context.go('/opportunities/${app.opportunityId}'),
          ),
        );
      },
    );
  }
}

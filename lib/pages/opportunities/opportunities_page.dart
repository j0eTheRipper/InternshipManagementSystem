import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/models/opportunity.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  List<Opportunity>? _opportunities;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _opportunities = await getOpportunities();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Opportunities',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse internship opportunities from partner companies.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            TextButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_opportunities == null || _opportunities!.isEmpty) {
      return const Center(
        child: Text(
          'No opportunities available yet.',
          style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _opportunities!.length,
        itemBuilder: (context, index) {
          final opp = _opportunities![index];
          return _OpportunityCard(
            company: opp.company ?? 'Unknown',
            role: opp.jobRole,
            title: opp.title,
            location: opp.location,
            status: opp.status,
            onTap: () => context.go('/opportunities/${opp.opportunityId}'),
          );
        },
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final String company;
  final String role;
  final String title;
  final String location;
  final String status;
  final VoidCallback onTap;

  const _OpportunityCard({
    required this.company,
    required this.role,
    required this.title,
    required this.location,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    company.isNotEmpty ? company[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF030213),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$company · $role',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717182),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status == 'remote'
                      ? const Color(0xFFE8F5E9)
                      : status == 'hybrid'
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status == 'remote'
                        ? const Color(0xFF2E7D32)
                        : status == 'hybrid'
                        ? const Color(0xFFE65100)
                        : const Color(0xFF1565C0),
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

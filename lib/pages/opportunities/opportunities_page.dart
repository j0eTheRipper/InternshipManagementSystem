import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/opportunity.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/opportunity.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  final List<Opportunity> _opportunities = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  int _matchedOffset = 0;
  int _otherOffset = 0;
  bool _hasMoreMatched = true;
  bool _hasMoreOther = true;
  bool _showingOthers = false;

  String? _fieldOfStudy;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fieldOfStudy = AuthState.currentStudent?.fieldOfStudy;
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _opportunities.clear();
      _matchedOffset = 0;
      _otherOffset = 0;
      _hasMoreMatched = true;
      _hasMoreOther = true;
      _showingOthers = false;
    });

    try {
      if (_fieldOfStudy != null && _fieldOfStudy!.isNotEmpty) {
        final results = await getOpportunities(
          fieldOfStudy: _fieldOfStudy,
          limit: _pageSize,
          offset: 0,
        );
        _matchedOffset = results.length;
        _hasMoreMatched = results.length >= _pageSize;
        _opportunities.addAll(results);
      } else {
        final results = await getOpportunities(limit: _pageSize, offset: 0);
        _matchedOffset = results.length;
        _hasMoreMatched = false;
        _opportunities.addAll(results);
      }
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);

    try {
      List<Opportunity> results;

      if (!_showingOthers && _hasMoreMatched && _fieldOfStudy != null) {
        results = await getOpportunities(
          fieldOfStudy: _fieldOfStudy,
          limit: _pageSize,
          offset: _matchedOffset,
        );
        _matchedOffset += results.length;
        _hasMoreMatched = results.length >= _pageSize;

        if (!_hasMoreMatched) {
          _showingOthers = true;
        }
      } else if (_hasMoreOther && _fieldOfStudy != null) {
        _showingOthers = true;
        results = await getOpportunities(
          fieldOfStudy: _fieldOfStudy,
          limit: _pageSize,
          offset: _otherOffset,
          otherFields: true,
        );
        _otherOffset += results.length;
        _hasMoreOther = results.length >= _pageSize;
      } else {
        results = [];
      }

      if (mounted) {
        setState(() {
          _opportunities.addAll(results);
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  bool get _hasMore =>
      (_fieldOfStudy != null && _fieldOfStudy!.isNotEmpty)
          ? (_hasMoreMatched || _hasMoreOther)
          : false;

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
    if (_error != null && _opportunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            TextButton(onPressed: _fetchInitial, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_opportunities.isEmpty) {
      return const Center(
        child: Text(
          'No opportunities available yet.',
          style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchInitial,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _opportunities.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _opportunities.length) {
            return _buildShowMoreButton();
          }

          final opp = _opportunities[index];
          return _OpportunityCard(
            company: opp.company ?? 'Unknown',
            role: opp.jobRole,
            fieldOfStudy: opp.fieldOfStudy,
            title: opp.title,
            location: opp.location,
            status: opp.status,
            onTap: () => context.go('/opportunities/${opp.opportunityId}'),
          );
        },
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (_showingOthers && _otherOffset <= _pageSize)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Explore opportunities in other fields',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _loadMore,
              child: const Text('Show more'),
            ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final String company;
  final String role;
  final String fieldOfStudy;
  final String title;
  final String location;
  final String status;
  final VoidCallback onTap;

  const _OpportunityCard({
    required this.company,
    required this.role,
    required this.fieldOfStudy,
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
                    if (fieldOfStudy.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        fieldOfStudy,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
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

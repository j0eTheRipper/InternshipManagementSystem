import 'package:flutter/material.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text(
            'Companies',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Browse internship opportunities from partner companies.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF717182),
            ),
          ),
        ],
      ),
    );
  }
}

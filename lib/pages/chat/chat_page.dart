import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Communicate with your mentor, supervisor, and peers.',
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

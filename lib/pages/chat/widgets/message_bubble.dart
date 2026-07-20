import 'package:flutter/material.dart';
import 'package:internship_management_system/auth/auth_state.dart';

class MessageBubble extends StatelessWidget {
  final int messageId;
  final int senderId;
  final String content;
  final String? createdAt;
  final bool isRead;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.messageId,
    required this.senderId,
    required this.content,
    this.createdAt,
    this.isRead = false,
    this.showTimestamp = true,
  });

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = senderId == AuthState.currentUser?.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFF0F0F0),
              child: Text(
                '?',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF717182),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                ),
                if (showTimestamp && createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 14,
                            color: isRead
                                ? const Color(0xFF5B9BF8)
                                : const Color(0xFFAAAAAA),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

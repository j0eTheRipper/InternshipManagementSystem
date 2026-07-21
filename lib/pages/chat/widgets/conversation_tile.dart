import 'package:flutter/material.dart';
import 'package:internship_management_system/models/conversation.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/utils/time.dart';

class ConversationTile extends StatelessWidget {
  final ConversationData conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Student';
      case 'universityMentor':
        return 'University Mentor';
      case 'companySupervisor':
        return 'Company Supervisor';
      case 'admin':
        return 'Admin';
      case 'headhunter':
        return 'Headhunter';
      default:
        return role;
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    final dt = parseServerTime(dateTimeStr);
    if (dt == null) return '';
    return formatRelativeTime(dt);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthState.currentUser?.userId;
    final isFromMe = conversation.lastSenderId != null &&
        conversation.lastSenderId == currentUserId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF5F5F5),
                child: Text(
                  _getInitials(conversation.otherUserName),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUserName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.lastMessageAt != null)
                          Text(
                            _formatTime(conversation.lastMessageAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: conversation.unreadCount > 0
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF717182),
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getRoleLabel(conversation.otherUserRole),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF717182),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isFromMe
                                ? 'You: ${conversation.lastMessage ?? ''}'
                                : (conversation.lastMessage ?? ''),
                            style: TextStyle(
                              fontSize: 13,
                              color: conversation.unreadCount > 0
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF717182),
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF030213),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : '${conversation.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

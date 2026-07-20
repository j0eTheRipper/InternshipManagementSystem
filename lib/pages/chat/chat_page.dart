import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/chat.dart';
import 'package:internship_management_system/models/conversation.dart';
import 'package:internship_management_system/models/contact.dart';
import 'package:internship_management_system/pages/chat/widgets/conversation_tile.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ConversationData> _conversations = [];
  List<ContactData> _contacts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([getConversations(), getContacts()]);
      if (mounted) {
        setState(() {
          _conversations = results[0] as List<ConversationData>;
          _contacts = results[1] as List<ContactData>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<ContactData> get _contactsNotMessaged {
    final messagedIds = _conversations.map((c) => c.otherUserId).toSet();
    return _contacts.where((c) => !messagedIds.contains(c.userId)).toList();
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
      default:
        return role;
    }
  }

  Future<void> _startConversation(ContactData contact) async {
    try {
      final conversationId = await createOrGetConversation(contact.userId);
      if (mounted) {
        context.push('/chat/$conversationId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
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
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF717182)),
            const SizedBox(height: 16),
            Text(
              'Failed to load',
              style: const TextStyle(fontSize: 16, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final hasConversations = _conversations.isNotEmpty;
    final hasContacts = _contactsNotMessaged.isNotEmpty;

    if (!hasConversations && !hasContacts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 4),
            const Text(
              'You don\'t have any contacts to message.',
              style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        if (hasConversations) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'RECENTLY MESSAGED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF999999),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ..._conversations.map((conversation) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: ConversationTile(
              conversation: conversation,
              onTap: () {
                context.push('/chat/${conversation.conversationId}');
              },
            ),
          )),
        ],
        if (hasContacts) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 20, 12, 8),
            child: Text(
              'CAN MESSAGE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF999999),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ..._contactsNotMessaged.map((contact) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _buildContactTile(contact),
          )),
        ],
      ],
    );
  }

  Widget _buildContactTile(ContactData contact) {
    final initials = contact.fullname.split(' ').length >= 2
        ? '${contact.fullname.split(' ')[0][0]}${contact.fullname.split(' ')[1][0]}'.toUpperCase()
        : (contact.fullname.isNotEmpty ? contact.fullname[0].toUpperCase() : '?');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _startConversation(contact),
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
                  initials,
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
                    Text(
                      contact.fullname,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getRoleLabel(contact.role),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF717182),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: Color(0xFFBBBBBB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

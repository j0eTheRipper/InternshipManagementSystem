import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internship_management_system/api/chat.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/message.dart';
import 'package:internship_management_system/services/chat_service.dart';
import 'package:internship_management_system/notifications/chat_notification_service.dart';
import 'package:internship_management_system/notifications/notification_service.dart';
import 'package:internship_management_system/pages/chat/widgets/message_bubble.dart';
import 'package:internship_management_system/pages/chat/widgets/typing_indicator.dart';

class ConversationPage extends StatefulWidget {
  final int conversationId;

  const ConversationPage({super.key, required this.conversationId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageData> _messages = [];
  final List<StreamSubscription> _subscriptions = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _isTyping = false;
  bool _otherOnline = false;
  String _otherName = '';
  String _otherRole = '';
  int? _oldestMessageId;

  @override
  void initState() {
    super.initState();
    _loadConversationInfo();
    _loadInitial();
    _connectWebSocket();
    _scrollController.addListener(_onScroll);
  }

  void _loadConversationInfo() async {
    try {
      final conversations = await getConversations();
      final match = conversations.where((c) => c.conversationId == widget.conversationId);
      if (match.isNotEmpty && mounted) {
        setState(() {
          _otherName = match.first.otherUserName;
          _otherRole = match.first.otherUserRole;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadInitial() async {
    try {
      final messages = await getMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages.addAll(messages);
          _loading = false;
          if (messages.isNotEmpty) {
            _oldestMessageId = messages.last.messageId;
            _hasMore = messages.length >= 50;
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        markConversationRead(widget.conversationId);
        ChatNotificationService.instance.fetchUnread();
        NotificationService.instance.fetchUnread();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _connectWebSocket() {
    final chatService = ChatService.instance;
    chatService.connect(widget.conversationId);

    _subscriptions.add(chatService.messageStream.listen((message) {
      if (!mounted) return;
      setState(() {
        _messages.insert(0, message);
      });
      _scrollToBottom();
      markConversationRead(widget.conversationId);
    }));

    _subscriptions.add(chatService.eventStream.listen((event) {
      if (!mounted) return;
      if (event['type'] == 'read') {
        final msgId = event['message_id'];
        if (msgId != null) {
          setState(() {
            for (var m in _messages) {
              if (m.messageId <= msgId) {
                m.isRead = true;
              }
            }
          });
        }
      }
    }));

    chatService.addListener(() {
      if (mounted) {
        setState(() {
          _otherOnline = chatService.otherUserOnline;
          _isTyping = chatService.otherUserTyping;
        });
      }
    });

    setState(() {
      _otherOnline = chatService.otherUserOnline;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore &&
        _oldestMessageId != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _oldestMessageId == null) return;
    setState(() => _loadingMore = true);

    try {
      final more = await getMessages(
        widget.conversationId,
        before: _oldestMessageId,
      );
      if (mounted && more.isNotEmpty) {
        setState(() {
          _messages.addAll(more);
          _oldestMessageId = more.last.messageId;
          _hasMore = more.length >= 50;
          _loadingMore = false;
        });
      } else if (mounted) {
        setState(() {
          _hasMore = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ChatService.instance.sendMessage(text);
    _controller.clear();
    ChatService.instance.stopTyping();
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      ChatService.instance.startTyping();
    } else if (text.isEmpty) {
      ChatService.instance.stopTyping();
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    ChatService.instance.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () {
            ChatService.instance.disconnect();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF5F5F5),
              child: Text(
                _otherName.isNotEmpty ? _otherName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherName.isNotEmpty ? _otherName : 'Chat',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    _otherOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: _otherOnline
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF717182),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final msg = _messages[index];
                      final showTimestamp = index == 0 ||
                          _messages[index - 1].senderId != msg.senderId;

                      return Column(
                        children: [
                          MessageBubble(
                            messageId: msg.messageId,
                            senderId: msg.senderId,
                            content: msg.content,
                            createdAt: msg.createdAt,
                            isRead: msg.isRead,
                            showTimestamp: showTimestamp,
                          ),
                          if (index == 0 && _isTyping)
                            TypingIndicator(userName: _otherName),
                        ],
                      );
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

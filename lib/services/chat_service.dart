import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/config.dart';
import 'package:internship_management_system/models/message.dart';
import 'package:internship_management_system/api/chat.dart';

class ChatService extends ChangeNotifier {
  ChatService._();
  static final ChatService _instance = ChatService._();
  static ChatService get instance => _instance;

  WebSocketChannel? _channel;
  int? _activeConversationId;
  bool _connected = false;
  bool _otherUserOnline = false;
  bool _otherUserTyping = false;
  Timer? _typingTimer;

  bool get connected => _connected;
  bool get otherUserOnline => _otherUserOnline;
  bool get otherUserTyping => _otherUserTyping;
  int? get activeConversationId => _activeConversationId;

  void connect(int conversationId) {
    disconnect();
    _activeConversationId = conversationId;

    final wsBase = baseUrl.replaceFirst('http', 'ws');
    final token = AuthState.token ?? '';
    final url = '$wsBase/ws/chat/$conversationId?token=$token';

    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (data) {
        final msg = jsonDecode(data);
        _handleMessage(msg);
      },
      onDone: () {
        _connected = false;
        _otherUserTyping = false;
        notifyListeners();
      },
      onError: (_) {
        _connected = false;
        notifyListeners();
      },
    );

    _connected = true;
    notifyListeners();
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _activeConversationId = null;
    _connected = false;
    _otherUserOnline = false;
    _otherUserTyping = false;
    _typingTimer?.cancel();
    notifyListeners();
  }

  void sendMessage(String content) {
    if (_channel == null || content.trim().isEmpty) return;
    _channel!.sink.add(jsonEncode({
      'type': 'message',
      'content': content.trim(),
    }));
  }

  void sendTyping(bool isTyping) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'typing',
      'is_typing': isTyping,
    }));
  }

  void startTyping() {
    sendTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      sendTyping(false);
    });
  }

  void stopTyping() {
    _typingTimer?.cancel();
    sendTyping(false);
  }

  void sendRead(int messageId) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'read',
      'message_id': messageId,
    }));
  }

  final StreamController<MessageData> _messageController = StreamController.broadcast();
  Stream<MessageData> get messageStream => _messageController.stream;

  final StreamController<Map<String, dynamic>> _eventController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['type'];

    switch (type) {
      case 'message':
        final message = MessageData(
          messageId: msg['message_id'],
          conversationId: _activeConversationId ?? 0,
          senderId: msg['sender_id'],
          content: msg['content'],
          createdAt: msg['created_at'],
        );
        _messageController.add(message);
        break;

      case 'typing':
        _otherUserTyping = msg['is_typing'] ?? false;
        notifyListeners();
        break;

      case 'online_status':
        _otherUserOnline = msg['is_online'] ?? false;
        notifyListeners();
        break;

      case 'read':
        _eventController.add(msg);
        break;
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.close();
    _eventController.close();
    _typingTimer?.cancel();
    super.dispose();
  }
}

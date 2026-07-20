import 'package:flutter/foundation.dart';
import 'package:internship_management_system/api/chat.dart';

class ChatNotificationService extends ChangeNotifier {
  ChatNotificationService._();
  static final ChatNotificationService _instance = ChatNotificationService._();
  static ChatNotificationService get instance => _instance;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  Future<void> fetchUnread() async {
    try {
      _unreadCount = await getChatUnreadTotal();
      notifyListeners();
    } catch (_) {}
  }

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}

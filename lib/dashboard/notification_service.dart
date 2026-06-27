import 'package:flutter/foundation.dart';
import 'package:internship_management_system/api/notification.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  Future<void> fetchUnread() async {
    try {
      _unreadCount = await getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}

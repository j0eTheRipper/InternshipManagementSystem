import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/config.dart';

Future<void> _onBackgroundMessage(RemoteMessage message) async {}

class PushNotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    final token = await _messaging.getToken();
    if (token != null) await _sendToken(token);

    _messaging.onTokenRefresh.listen(_sendToken);

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }

  static Future<void> sendCurrentToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _sendToken(token);
  }

  static Future<void> deleteToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    try {
      final url = Uri.parse('$baseUrl/fcm-token');
      await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthState.token}',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {}
    await _messaging.deleteToken();
  }

  static Future<void> _sendToken(String token) async {
    if (AuthState.token == null) return;
    try {
      final url = Uri.parse('$baseUrl/fcm-token');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthState.token}',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {}
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    debugPrint('FCM: ${notification.title} - ${notification.body}');
  }
}

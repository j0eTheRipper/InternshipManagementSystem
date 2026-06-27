class NotificationData {
  int notificationId;
  int userId;
  String message;
  String type;
  int? relatedId;
  bool isRead;
  String? createdAt;

  NotificationData({
    required this.notificationId,
    required this.userId,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      message: json['message'],
      type: json['type'],
      relatedId: json['related_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'],
    );
  }
}

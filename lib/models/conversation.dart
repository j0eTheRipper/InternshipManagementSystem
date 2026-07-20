class ConversationData {
  int conversationId;
  int otherUserId;
  String otherUserName;
  String otherUserRole;
  String? lastMessage;
  String? lastMessageAt;
  int? lastSenderId;
  int unreadCount;

  ConversationData({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserRole,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderId,
    this.unreadCount = 0,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      conversationId: json['conversation_id'],
      otherUserId: json['other_user_id'],
      otherUserName: json['other_user_name'],
      otherUserRole: json['other_user_role'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'],
      lastSenderId: json['last_sender_id'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class MessageData {
  int messageId;
  int conversationId;
  int senderId;
  String content;
  String? createdAt;
  bool isRead;

  MessageData({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.createdAt,
    this.isRead = false,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      messageId: json['message_id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: json['created_at'],
      isRead: json['is_read'] ?? false,
    );
  }
}

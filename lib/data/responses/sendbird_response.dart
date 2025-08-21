import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? senderId;
  final String? senderName;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.senderId,
    this.senderName,
    this.metadata,
  });

  factory ChatMessage.fromSendbird(BaseMessage message) {
    return ChatMessage(
      id: message.messageId.toString(),
      text: message is UserMessage ? message.message : '',
      isMe: message.sender?.userId == SendbirdSdk().currentUser?.userId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
      senderId: message.sender?.userId,
      senderName: message.sender?.nickname,
      metadata: message.data != null ? {'data': message.data} : null,
    );
  }

  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

class Conversation {
  final String id;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.title,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory Conversation.fromSendbird(GroupChannel channel) {
    String? lastMessageText;
    if (channel.lastMessage != null && channel.lastMessage is UserMessage) {
      lastMessageText = (channel.lastMessage as UserMessage).message;
    }

    return Conversation(
      id: channel.channelUrl,
      title: (channel.name?.isNotEmpty ?? false) ? channel.name! : 'Cuộc trò chuyện',
      lastMessage: lastMessageText,
      lastMessageTime: channel.lastMessage != null
          ? DateTime.fromMillisecondsSinceEpoch(channel.lastMessage!.createdAt)
          : null,
      unreadCount: channel.unreadMessageCount,
      isOnline: channel.memberCount > 1,
    );
  }

  String get timeString {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Conversation copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

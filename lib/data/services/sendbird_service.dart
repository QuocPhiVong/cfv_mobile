import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../../controller/auth_controller.dart';

class SendbirdService {
  static SendbirdService? _instance;
  static SendbirdService get instance => _instance ??= SendbirdService._();

  SendbirdService._();

  bool _isInitialized = false;
  bool _isUserConnected = false;
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();

  // Sendbird configuration
  static const String _applicationId = '76B840AB-32EE-4792-B6C7-98FC3101C9D7';
  static const String _apiToken = 'e4287fa793034582f027ac596bf2e1848faaec17';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing Sendbird SDK...');

      // Initialize Sendbird SDK properly
      SendbirdSdk(appId: _applicationId, apiToken: _apiToken);

      _isInitialized = true;

      debugPrint('✅ Sendbird SDK initialized successfully!');
      debugPrint('   App ID: $_applicationId');
    } catch (e) {
      debugPrint('❌ Failed to initialize Sendbird: $e');
      rethrow;
    }
  }

  Future<bool> connectUser(String userId, String nickname) async {
    if (!_isInitialized) await initialize();

    try {
      // Check if user is already connected
      if (_isUserConnected && SendbirdSdk().currentUser?.userId == userId) {
        debugPrint('✅ User already connected: $userId ($nickname)');
        return true;
      }

      debugPrint('🔄 Connecting user: $userId ($nickname)...');

      // Connect user
      await SendbirdSdk().connect(
        userId,
        nickname: nickname,
        apiHost: "api-76B840AB-32EE-4792-B6C7-98FC3101C9D7.sendbird.com",
      );

      _isUserConnected = true;

      // Log successful connection with user details
      final currentUser = SendbirdSdk().currentUser;
      debugPrint('✅ Successfully connected to Sendbird!');
      debugPrint('   User ID: ${currentUser?.userId}');
      debugPrint('   Nickname: ${currentUser?.nickname}');
      debugPrint('   Connection Status: $_isUserConnected');

      return true;
    } catch (e) {
      debugPrint('❌ Failed to connect user: $e');
      _isUserConnected = false;
      return false;
    }
  }

  Future<bool> _ensureUserConnected() async {
    if (!_isUserConnected) {
      // Auto-connect with a default user if not connected
      final userId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';
      final name = Get.find<AuthenticationController>().currentUser?.name ?? '';
      return await connectUser(userId, name);
    }
    return true;
  }

  Future<List<ChatMessage>> getChatHistory(String channelUrl) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return [];

    try {
      // Validate channel URL
      if (channelUrl.isEmpty) {
        debugPrint('Channel URL is empty');
        return [];
      }

      final channel = await GroupChannel.getChannel(channelUrl);

      // Basic channel validation
      if (channel.channelUrl.isEmpty) {
        debugPrint('Channel URL is empty after getting channel');
        return [];
      }

      // Use proper message loading parameters
      final params = MessageListParams()
        ..previousResultSize = 50
        ..includeReactions = false
        ..includeThreadInfo = false
        ..includeParentMessageInfo = false;

      final messages = await channel.getMessagesByTimestamp(DateTime.now().millisecondsSinceEpoch, params);

      debugPrint('Messages: ${messages.length}');
      return messages.map((msg) => ChatMessage.fromSendbird(msg)).toList();
    } catch (e) {
      debugPrint('Failed to get chat history: $e');
      // Return empty list instead of throwing error
      return [];
    }
  }

  Future<void> sendMessage(String channelUrl, String text) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return;

    try {
      // Validate channel URL
      if (channelUrl.isEmpty) {
        debugPrint('Channel URL is empty');
        return;
      }

      final channel = await GroupChannel.getChannel(channelUrl);

      // Basic channel validation
      if (channel.channelUrl.isEmpty) {
        debugPrint('Channel URL is empty after getting channel');
        return;
      }

      final params = UserMessageParams(message: text);

      // Send message (no await needed in v3)
      channel.sendUserMessage(params);
    } catch (e) {
      debugPrint('Failed to send message: $e');
      rethrow;
    }
  }

  Future<List<Conversation>> getConversations() async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return [];

    try {
      final query = GroupChannelListQuery();
      final channels = await query.loadNext();

      debugPrint('✅ Successfully loaded ${channels.length} conversations');
      return channels.map((channel) => Conversation.fromSendbird(channel)).toList();
    } catch (e) {
      debugPrint('Failed to get conversations: $e');
      return [];
    }
  }

  Stream<ChatMessage> getMessageStream(String channelUrl) {
    if (!_isInitialized) {
      initialize();
    }

    return _messageController.stream;
  }

  Future<String> createConversation(String title, {String? initialMessage}) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) throw Exception('User not connected');

    try {
      // Validate title
      if (title.isEmpty) {
        throw Exception('Conversation title cannot be empty');
      }

      final currentUserId = SendbirdSdk().currentUser?.userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Current user ID is null or empty');
      }

      final params = GroupChannelParams()
        ..name = title
        ..userIds = [currentUserId];

      debugPrint('🔄 Creating conversation: $title...');

      final channel = await GroupChannel.createChannel(params);

      // Validate created channel
      if (channel.channelUrl.isEmpty) {
        throw Exception('Failed to create channel: channel URL is empty');
      }

      debugPrint('✅ Successfully created conversation!');
      debugPrint('   Title: $title');
      debugPrint('   Channel URL: ${channel.channelUrl}');

      if (initialMessage != null && initialMessage.isNotEmpty) {
        debugPrint('📤 Sending initial message: $initialMessage');
        await sendMessage(channel.channelUrl, initialMessage);
      }

      return channel.channelUrl;
    } catch (e) {
      debugPrint('Failed to create conversation: $e');
      rethrow;
    }
  }

  Future<void> joinChannel(String channelUrl) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return;

    try {
      await GroupChannel.getChannel(channelUrl);
      // Group channels don't require explicit joining in Sendbird v3
      // Users are automatically members when added to the channel
    } catch (e) {
      debugPrint('Failed to join channel: $e');
      rethrow;
    }
  }

  void dispose() {
    _messageController.close();
    _isInitialized = false;
    _isUserConnected = false;
  }
}

// Data models for chat
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
      isOnline: channel.memberCount > 1, // More than just current user
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
}

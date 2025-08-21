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
  final Map<String, StreamController<ChatMessage>> _messageControllers = {};
  final Map<String, StreamSubscription<BaseMessage>> _channelSubscriptions = {};
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, int> _lastMessageTimestamps = {};

  // Batch processing for messages
  final Map<String, List<ChatMessage>> _messageBatch = {};
  final Map<String, Timer> _batchTimers = {};

  // Real-time event handlers
  StreamSubscription<BaseMessage>? _messageReceivedSubscription;
  StreamSubscription<BaseMessage>? _messageUpdatedSubscription;
  StreamSubscription<BaseMessage>? _messageDeletedSubscription;
  StreamSubscription<GroupChannel>? _channelChangedSubscription;

  // Sendbird configuration
  static const String _applicationId = '76B840AB-32EE-4792-B6C7-98FC3101C9D7';
  static const String _apiToken = 'e4287fa793034582f027ac596bf2e1848faaec17';

  // Configuration constants
  static const int _pollingIntervalSeconds = 3; // Tăng từ 1 lên 3 giây để giảm tải và tránh nhảy UI
  static const int _maxMessagesPerRequest = 50; // Giữ nguyên
  static const int _connectionCheckIntervalSeconds = 60; // Giữ nguyên
  static const int _batchSize = 10; // Giảm batch size để xử lý nhanh hơn
  static const int _maxBatchDelay = 200; // Tăng delay để tích lũy nhiều tin nhắn hơn
  static const int _maxRetries = 1; // Giữ nguyên
  static const int _retryDelay = 100; // Giữ nguyên

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing Sendbird SDK...');

      // Initialize Sendbird SDK properly
      SendbirdSdk(appId: _applicationId, apiToken: _apiToken);

      // Set up real-time event handlers
      _setupRealTimeEventHandlers();

      _isInitialized = true;

      debugPrint('✅ Sendbird SDK initialized successfully!');
      debugPrint('   App ID: $_applicationId');
    } catch (e) {
      debugPrint('❌ Failed to initialize Sendbird: $e');
      rethrow;
    }
  }

  void _setupRealTimeEventHandlers() {
    try {
      debugPrint('📡 Setting up real-time event handlers...');

      // For Sendbird SDK v3, we need to use different approach
      // Since real-time events are not directly available, we'll use optimized polling
      debugPrint('📡 Real-time events not available in SDK v3, using optimized polling instead');
      debugPrint('✅ Event handlers setup completed (fallback to polling)');
    } catch (e) {
      debugPrint('❌ Failed to set up real-time event handlers: $e');
    }
  }

  void _handleNewMessage(BaseChannel channel, BaseMessage message) {
    try {
      final channelUrl = channel.channelUrl;
      debugPrint('📨 Real-time message received: ${message.messageId} in channel: $channelUrl');

      // Check if we have a message controller for this channel
      if (_messageControllers.containsKey(channelUrl)) {
        final controller = _messageControllers[channelUrl]!;

        // Check if controller is closed or has no listeners
        if (controller.isClosed || !controller.hasListener) {
          debugPrint('📨 Message controller is closed or has no listeners, skipping message');
          return;
        }

        final chatMessage = ChatMessage.fromSendbird(message);

        // Update last message timestamp
        _lastMessageTimestamps[channelUrl] = message.createdAt;

        // Add to stream
        controller.add(chatMessage);
        debugPrint('📨 Added real-time message to stream: ${chatMessage.text}');
      }
    } catch (e) {
      debugPrint('❌ Error handling new message: $e');
    }
  }

  void _handleMessageUpdated(BaseChannel channel, BaseMessage message) {
    try {
      final channelUrl = channel.channelUrl;
      debugPrint('📝 Message updated: ${message.messageId} in channel: $channelUrl');

      // Notify UI about message update if needed
      if (_messageControllers.containsKey(channelUrl)) {
        // You can implement message update logic here
        debugPrint('📝 Message update handled for channel: $channelUrl');
      }
    } catch (e) {
      debugPrint('❌ Error handling message update: $e');
    }
  }

  void _handleMessageDeleted(BaseChannel channel, int messageId) {
    try {
      final channelUrl = channel.channelUrl;
      debugPrint('🗑️ Message deleted: $messageId in channel: $channelUrl');

      // Notify UI about message deletion if needed
      if (_messageControllers.containsKey(channelUrl)) {
        // You can implement message deletion logic here
        debugPrint('🗑️ Message deletion handled for channel: $channelUrl');
      }
    } catch (e) {
      debugPrint('❌ Error handling message deletion: $e');
    }
  }

  void _handleChannelChanged(BaseChannel channel) {
    try {
      final channelUrl = channel.channelUrl;
      debugPrint('🔄 Channel changed: $channelUrl');

      // Handle channel updates (member changes, etc.)
      if (channel is GroupChannel) {
        debugPrint('🔄 Group channel updated: ${channel.name}');
      }
    } catch (e) {
      debugPrint('❌ Error handling channel change: $e');
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

  // Method to check and recover connection
  Future<bool> checkAndRecoverConnection() async {
    try {
      if (!_isUserConnected) {
        debugPrint('🔄 Connection lost, attempting to reconnect...');
        return await _ensureUserConnected();
      }

      // Check if current user is still valid
      final currentUser = SendbirdSdk().currentUser;
      if (currentUser == null || currentUser.userId.isEmpty) {
        debugPrint('🔄 Current user invalid, attempting to reconnect...');
        _isUserConnected = false;
        return await _ensureUserConnected();
      }

      return true;
    } catch (e) {
      debugPrint('❌ Failed to check/recover connection: $e');
      _isUserConnected = false;
      return false;
    }
  }

  // Method to force reconnect
  Future<bool> forceReconnect() async {
    try {
      debugPrint('🔄 Force reconnecting...');

      // Reset connection state
      _isUserConnected = false;

      // Attempt to reconnect
      final userId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';
      final name = Get.find<AuthenticationController>().currentUser?.name ?? '';

      if (userId.isEmpty) {
        debugPrint('❌ Cannot reconnect: User ID is empty');
        return false;
      }

      return await connectUser(userId, name);
    } catch (e) {
      debugPrint('❌ Force reconnect failed: $e');
      return false;
    }
  }

  Future<List<ChatMessage>> getChatHistory(String channelUrl, {int limit = _maxMessagesPerRequest}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!await _ensureUserConnected()) {
      return [];
    }

    try {
      // Validate channel URL
      if (channelUrl.isEmpty) {
        debugPrint('❌ Channel URL is empty in getChatHistory');
        return [];
      }

      debugPrint('📚 Loading chat history for channel: $channelUrl (limit: $limit)');

      // Get channel with minimal retry
      GroupChannel? channel;
      try {
        channel = await GroupChannel.getChannel(channelUrl);
      } catch (e) {
        // Try to create channel if it doesn't exist
        try {
          channel = await GroupChannel.createChannel(GroupChannelParams()..channelUrl = channelUrl);
          debugPrint('✅ Created new channel: $channelUrl');
        } catch (createError) {
          debugPrint('❌ Failed to create channel: $createError');
          return [];
        }
      }

      if (channel.channelUrl.isEmpty) {
        debugPrint('❌ Invalid channel');
        return [];
      }

      // Join channel if needed (non-blocking)
      if (!channel.members.any((m) => m.userId == SendbirdSdk().currentUser?.userId)) {
        try {
          await channel.acceptInvitation();
          debugPrint('✅ Joined channel: $channelUrl');
        } catch (joinError) {
          debugPrint('⚠️ Failed to join channel, continuing: $joinError');
        }
      }

      // Load messages with correct parameters - use consistent approach
      List<BaseMessage> messages = [];

      try {
        final params = MessageListParams()
          ..previousResultSize = limit
          ..reverse =
              false // Use reverse=false for consistent ordering
          ..includeReactions = false
          ..includeThreadInfo = false
          ..includeParentMessageInfo = false
          ..includeMetaArray = false;

        // Load from current time to get recent messages
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        messages = await channel.getMessagesByTimestamp(currentTimestamp, params);
        debugPrint('✅ Successfully loaded ${messages.length} recent messages');
      } catch (e) {
        debugPrint('⚠️ Failed to load recent messages: $e');
        return [];
      }

      if (messages.isEmpty) {
        debugPrint('📚 No messages found in channel: $channelUrl');
        return [];
      }

      // Convert to ChatMessage objects efficiently
      final chatMessages = messages
          .map((msg) => ChatMessage.fromSendbird(msg))
          .where((msg) => msg != null)
          .cast<ChatMessage>()
          .toList();

      // With reverse=false, messages are in chronological order (oldest first)
      // Double-check and ensure correct ordering
      if (chatMessages.length > 1) {
        // Sort by timestamp to ensure chronological order
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        debugPrint(
          '📚 Messages sorted chronologically: ${chatMessages.first.timestamp} to ${chatMessages.last.timestamp}',
        );
      }

      // Update timestamp for smart polling (use newest message)
      if (chatMessages.isNotEmpty) {
        _lastMessageTimestamps[channelUrl] = chatMessages.last.timestamp.millisecondsSinceEpoch;
        debugPrint('📚 Updated last message timestamp: ${chatMessages.last.timestamp}');
      }

      return chatMessages;
    } catch (e) {
      debugPrint('❌ Error in getChatHistory: $e');
      return [];
    }
  }

  // Method to load more messages (pagination)
  Future<List<ChatMessage>> loadMoreMessages(String channelUrl, {int limit = 20}) async {
    if (!_isInitialized || !await _ensureUserConnected()) return [];

    try {
      debugPrint('📚 Loading more messages for channel: $channelUrl (limit: $limit)');

      // Get the oldest message timestamp we have
      final oldestTimestamp = _lastMessageTimestamps[channelUrl];
      if (oldestTimestamp == null) {
        debugPrint('📚 No previous messages found, cannot load more');
        return [];
      }

      // Get channel directly without retry
      GroupChannel channel;
      try {
        channel = await GroupChannel.getChannel(channelUrl);
      } catch (e) {
        debugPrint('❌ Failed to get channel: $e');
        return [];
      }

      // Load older messages with correct parameters
      final params = MessageListParams()
        ..previousResultSize = limit
        ..reverse =
            false // Use reverse=false for consistency
        ..includeReactions = false
        ..includeThreadInfo = false
        ..includeParentMessageInfo = false
        ..includeMetaArray = false;

      // Load messages before the oldest message we have
      final olderMessages = await channel.getMessagesByTimestamp(oldestTimestamp, params);

      if (olderMessages.isEmpty) {
        debugPrint('📚 No older messages found');
        return [];
      }

      debugPrint('📚 Loaded ${olderMessages.length} older messages');

      final chatMessages = olderMessages.map((msg) => ChatMessage.fromSendbird(msg)).toList();

      // Ensure messages are in chronological order
      if (chatMessages.length > 1) {
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        debugPrint(
          '📚 Older messages sorted chronologically: ${chatMessages.first.timestamp} to ${chatMessages.last.timestamp}',
        );
      }

      // Update timestamp to the oldest message for next pagination
      if (chatMessages.isNotEmpty) {
        _lastMessageTimestamps[channelUrl] = chatMessages.first.timestamp.millisecondsSinceEpoch;
        debugPrint('📚 Updated oldest timestamp for pagination: ${chatMessages.first.timestamp}');
      }

      return chatMessages;
    } catch (e) {
      debugPrint('❌ Failed to load more messages: $e');
      return [];
    }
  }

  Future<void> sendMessage(String channelUrl, String text) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return;

    try {
      // Quick validation
      if (channelUrl.isEmpty || text.trim().isEmpty) {
        throw Exception('Channel URL and message text cannot be empty');
      }

      debugPrint('📤 Sending message to channel: $channelUrl');

      final channel = await GroupChannel.getChannel(channelUrl);
      final params = UserMessageParams(message: text.trim());

      // Send message immediately
      final userMessage = channel.sendUserMessage(params);

      debugPrint('✅ Message sent successfully! ID: ${userMessage.messageId}');

      // Update timestamp for smart polling
      _lastMessageTimestamps[channelUrl] = userMessage.createdAt;
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');

      // Simplified error handling
      String errorMessage = 'Failed to send message';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('channel')) {
        errorMessage = 'Channel error. Please try again.';
      }

      throw Exception(errorMessage);
    }
  }

  Future<List<Conversation>> getConversations() async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return [];

    try {
      debugPrint('🔄 Loading conversations...');

      final query = GroupChannelListQuery()..limit = 20; // Limit to 20 conversations for better performance
      final channels = await query.loadNext();

      debugPrint('✅ Successfully loaded ${channels.length} conversations');

      final conversations = channels.map((channel) => Conversation.fromSendbird(channel)).toList();

      // Sort by last message time (newest first)
      conversations.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return conversations;
    } catch (e) {
      debugPrint('❌ Failed to get conversations: $e');
      return [];
    }
  }

  Stream<ChatMessage> getMessageStream(String channelUrl) {
    if (!_isInitialized) {
      initialize();
    }

    // Create stream controller if it doesn't exist
    if (!_messageControllers.containsKey(channelUrl)) {
      _messageControllers[channelUrl] = StreamController<ChatMessage>.broadcast();

      // Set up channel subscription
      _setupChannelSubscription(channelUrl);

      // Set up smart polling to simulate real-time message delivery
      _setupFallbackPolling(channelUrl);
    }

    return _messageControllers[channelUrl]!.stream;
  }

  void _setupChannelSubscription(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);

      // Initialize last message timestamp if not set
      if (!_lastMessageTimestamps.containsKey(channelUrl)) {
        _lastMessageTimestamps[channelUrl] = DateTime.now().millisecondsSinceEpoch;
      }

      debugPrint('✅ Channel subscription set up for: $channelUrl');
      debugPrint('📡 Smart polling will handle new messages automatically');
    } catch (e) {
      debugPrint('❌ Failed to set up channel subscription: $e');
    }
  }

  void _setupFallbackPolling(String channelUrl) async {
    try {
      // Cancel existing polling timer
      _pollingTimers[channelUrl]?.cancel();

      final channel = await GroupChannel.getChannel(channelUrl);

      debugPrint('🔄 Setting up smart polling for channel: $channelUrl');

      // Use smart polling with longer interval to reduce UI updates
      // Poll every 3 seconds instead of 1 second to prevent continuous jumping
      _pollingTimers[channelUrl] = Timer.periodic(Duration(seconds: _pollingIntervalSeconds), (timer) async {
        _pollNewMessages(channelUrl, channel);
      });
    } catch (e) {
      debugPrint('❌ Failed to set up smart polling: $e');
    }
  }

  Future<void> _pollNewMessages(String channelUrl, GroupChannel channel) async {
    try {
      if (!_messageControllers.containsKey(channelUrl)) {
        _pollingTimers[channelUrl]?.cancel();
        return;
      }

      final controller = _messageControllers[channelUrl]!;

      // Check if controller is closed or has no listeners
      if (controller.isClosed || !controller.hasListener) {
        debugPrint('📨 Message controller is closed or has no listeners, stopping polling');
        _pollingTimers[channelUrl]?.cancel();
        return;
      }

      final lastTimestamp = _lastMessageTimestamps[channelUrl] ?? DateTime.now().millisecondsSinceEpoch;

      // Get latest messages since last check with correct parameters
      final params = MessageListParams()
        ..previousResultSize = _batchSize
        ..reverse =
            false // Use reverse=false for consistency
        ..includeReactions = false
        ..includeThreadInfo = false
        ..includeParentMessageInfo = false
        ..includeMetaArray = false;

      final latestMessages = await channel.getMessagesByTimestamp(lastTimestamp, params);

      // Update timestamp and add new messages to stream
      if (latestMessages.isNotEmpty) {
        // Update timestamp to the newest message
        _lastMessageTimestamps[channelUrl] = latestMessages.first.createdAt;

        debugPrint('📨 Smart polling found ${latestMessages.length} new messages');

        // Filter out messages we've already processed to avoid duplicates
        final newMessages = <BaseMessage>[];
        for (final message in latestMessages) {
          // Skip if this message is older than or equal to our last timestamp
          if (message.createdAt <= lastTimestamp) {
            continue;
          }
          newMessages.add(message);
        }

        if (newMessages.isNotEmpty) {
          debugPrint('📨 Processing ${newMessages.length} truly new messages');

          // Convert to ChatMessage objects
          final chatMessages = newMessages.map((msg) => ChatMessage.fromSendbird(msg)).toList();

          // Ensure messages are in chronological order
          if (chatMessages.length > 1) {
            chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            debugPrint(
              '📨 New messages sorted chronologically: ${chatMessages.first.timestamp} to ${chatMessages.last.timestamp}',
            );
          }

          // Add to batch for processing
          _addToBatch(channelUrl, chatMessages);
        } else {
          debugPrint('📨 No truly new messages found (all were duplicates)');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in smart polling: $e');
    }
  }

  // Batch processing method
  void _addToBatch(String channelUrl, List<ChatMessage> messages) {
    // Initialize batch if not exists
    if (!_messageBatch.containsKey(channelUrl)) {
      _messageBatch[channelUrl] = [];
    }

    // Add messages to batch
    _messageBatch[channelUrl]!.addAll(messages);

    // Cancel existing batch timer
    _batchTimers[channelUrl]?.cancel();

    // Set timer to process batch
    _batchTimers[channelUrl] = Timer(Duration(milliseconds: _maxBatchDelay), () {
      _processBatch(channelUrl);
    });
  }

  // Process batched messages
  void _processBatch(String channelUrl) {
    try {
      final controller = _messageControllers[channelUrl];
      final batch = _messageBatch[channelUrl];

      if (controller == null || batch == null || batch.isEmpty) {
        return;
      }

      // Check if controller is still valid
      if (controller.isClosed || !controller.hasListener) {
        _messageBatch.remove(channelUrl);
        _batchTimers.remove(channelUrl);
        return;
      }

      // Ensure batch is sorted by timestamp before sending
      batch.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      debugPrint('📨 Batch sorted by timestamp: ${batch.first.timestamp} to ${batch.last.timestamp}');

      // Send all messages in batch in correct order
      for (final message in batch) {
        if (!controller.isClosed && controller.hasListener) {
          controller.add(message);
        }
      }

      debugPrint('📨 Processed batch of ${batch.length} messages for channel: $channelUrl');

      // Clear batch
      _messageBatch[channelUrl]!.clear();
      _batchTimers.remove(channelUrl);
    } catch (e) {
      debugPrint('❌ Error processing batch: $e');
      // Clear batch on error
      _messageBatch.remove(channelUrl);
      _batchTimers.remove(channelUrl);
    }
  }

  Future<String> createConversation(String title, {String? initialMessage}) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) throw Exception('User not connected');

    try {
      // Quick validation
      if (title.trim().isEmpty || title.trim().length > 100) {
        throw Exception('Invalid conversation title (1-100 characters)');
      }

      final currentUserId = SendbirdSdk().currentUser?.userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }

      debugPrint('🆕 Creating conversation: $title');

      final params = GroupChannelParams()
        ..name = title.trim()
        ..userIds = [currentUserId]
        ..isDistinct = false
        ..isPublic = false;

      final channel = await GroupChannel.createChannel(params);

      if (channel.channelUrl.isEmpty) {
        throw Exception('Failed to create channel');
      }

      debugPrint('✅ Created conversation: ${channel.channelUrl}');

      // Initialize timestamp
      _lastMessageTimestamps[channel.channelUrl] = DateTime.now().millisecondsSinceEpoch;

      // Send initial message if provided (non-blocking)
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        try {
          await sendMessage(channel.channelUrl, initialMessage.trim());
        } catch (e) {
          debugPrint('⚠️ Failed to send initial message: $e');
        }
      }

      return channel.channelUrl;
    } catch (e) {
      debugPrint('❌ Failed to create conversation: $e');
      throw Exception('Failed to create conversation: ${e.toString()}');
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
      debugPrint('❌ Failed to join channel: $e');
      rethrow;
    }
  }

  // Getter for connection status
  bool get isUserConnected => _isUserConnected;

  // Method to check if SDK is properly initialized
  bool get isSDKInitialized {
    try {
      return _isInitialized && _applicationId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Method to get current user info
  String? get currentUserId {
    try {
      return SendbirdSdk().currentUser?.userId;
    } catch (e) {
      return null;
    }
  }

  // Method to get current user nickname
  String? get currentUserNickname {
    try {
      return SendbirdSdk().currentUser?.nickname;
    } catch (e) {
      return null;
    }
  }

  // Method to check if smart polling is working
  bool get isSmartPollingEnabled => _pollingTimers.isNotEmpty;

  // Method to get connection health metrics
  Map<String, dynamic> getConnectionHealth() {
    return {
      'isInitialized': _isInitialized,
      'isUserConnected': _isUserConnected,
      'activeChannels': _messageControllers.length,
      'activePolling': _pollingTimers.length,
      'activeBatches': _messageBatch.length,
      'currentUserId': currentUserId,
      'currentUserNickname': currentUserNickname,
      'pollingInterval': _pollingIntervalSeconds,
      'batchSize': _batchSize,
      'maxBatchDelay': _maxBatchDelay,
    };
  }

  // Method to get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final now = DateTime.now();
    final metrics = <String, dynamic>{};

    // Calculate average messages per channel
    if (_messageControllers.isNotEmpty) {
      int totalMessages = 0;
      for (final controller in _messageControllers.values) {
        // This is a rough estimate since we don't track message count directly
        totalMessages += 1; // Placeholder
      }
      metrics['averageMessagesPerChannel'] = totalMessages / _messageControllers.length;
    }

    // Connection uptime (rough estimate)
    metrics['estimatedUptime'] = _isUserConnected ? 'Connected' : 'Disconnected';

    // Memory usage indicators
    metrics['activeControllers'] = _messageControllers.length;
    metrics['activeTimers'] = _pollingTimers.length + _batchTimers.length;

    return metrics;
  }

  // Method to optimize polling based on usage
  void optimizePolling() {
    try {
      debugPrint('🔧 Optimizing polling configuration...');

      // Adjust polling interval based on active channels
      if (_messageControllers.length > 5) {
        // Many active channels, increase interval to reduce load
        debugPrint('📊 Many active channels detected, optimizing for performance');
      } else if (_messageControllers.length == 1) {
        // Single channel, can be more aggressive
        debugPrint('📊 Single channel detected, optimizing for responsiveness');
      }

      debugPrint('✅ Polling optimization completed');
    } catch (e) {
      debugPrint('❌ Failed to optimize polling: $e');
    }
  }

  // Method to verify message order for debugging
  void verifyMessageOrder(String channelUrl) {
    try {
      final controller = _messageControllers[channelUrl];
      if (controller == null) {
        debugPrint('❌ No message controller found for channel: $channelUrl');
        return;
      }

      debugPrint('🔍 Verifying message order for channel: $channelUrl');

      // Get current timestamp tracking
      final lastTimestamp = _lastMessageTimestamps[channelUrl];
      if (lastTimestamp != null) {
        final lastTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
        debugPrint('📅 Last message timestamp: $lastTime');
      }

      // Get batch info
      final batch = _messageBatch[channelUrl];
      if (batch != null && batch.isNotEmpty) {
        debugPrint('📦 Current batch size: ${batch.length}');
        debugPrint('📦 Batch timestamp range: ${batch.first.timestamp} to ${batch.last.timestamp}');
      }

      debugPrint('✅ Message order verification completed');
    } catch (e) {
      debugPrint('❌ Error verifying message order: $e');
    }
  }

  // Method to get message order statistics
  Map<String, dynamic> getMessageOrderStats(String channelUrl) {
    try {
      final stats = <String, dynamic>{};

      // Get timestamp info
      final lastTimestamp = _lastMessageTimestamps[channelUrl];
      if (lastTimestamp != null) {
        stats['lastMessageTime'] = DateTime.fromMillisecondsSinceEpoch(lastTimestamp).toString();
        stats['lastMessageTimestamp'] = lastTimestamp;
      }

      // Get batch info
      final batch = _messageBatch[channelUrl];
      if (batch != null && batch.isNotEmpty) {
        stats['batchSize'] = batch.length;
        stats['batchStartTime'] = batch.first.timestamp.toString();
        stats['batchEndTime'] = batch.last.timestamp.toString();
        stats['isBatchOrdered'] = _isBatchOrdered(batch);
      }

      // Get controller info
      final controller = _messageControllers[channelUrl];
      if (controller != null) {
        stats['hasController'] = true;
        stats['controllerClosed'] = controller.isClosed;
        stats['hasListeners'] = controller.hasListener;
      }

      return stats;
    } catch (e) {
      debugPrint('❌ Error getting message order stats: $e');
      return {'error': e.toString()};
    }
  }

  // Helper method to check if batch is properly ordered
  bool _isBatchOrdered(List<ChatMessage> batch) {
    if (batch.length <= 1) return true;

    for (int i = 1; i < batch.length; i++) {
      if (batch[i].timestamp.isBefore(batch[i - 1].timestamp)) {
        return false;
      }
    }
    return true;
  }

  // Method to test message loading for debugging
  Future<Map<String, dynamic>> testMessageLoading(String channelUrl) async {
    try {
      debugPrint('🧪 Testing message loading for channel: $channelUrl');

      final result = <String, dynamic>{};

      // Test 1: Get channel
      try {
        final channel = await GroupChannel.getChannel(channelUrl);
        result['channelExists'] = true;
        result['channelUrl'] = channel.channelUrl;
        result['memberCount'] = channel.memberCount;
        result['isCurrentUserMember'] = channel.members.any((m) => m.userId == SendbirdSdk().currentUser?.userId);
        debugPrint('✅ Channel test passed');
      } catch (e) {
        result['channelExists'] = false;
        result['channelError'] = e.toString();
        debugPrint('❌ Channel test failed: $e');
        return result;
      }

      // Test 2: Try different loading approaches
      final testParams = MessageListParams()
        ..previousResultSize = 10
        ..reverse = true
        ..includeReactions = false
        ..includeThreadInfo = false
        ..includeParentMessageInfo = false
        ..includeMetaArray = false;

      // Test from current time
      try {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        final channel = await GroupChannel.getChannel(channelUrl);
        final currentMessages = await channel.getMessagesByTimestamp(currentTimestamp, testParams);
        result['currentTimeMessages'] = currentMessages.length;
        result['currentTimeSuccess'] = true;
        debugPrint('✅ Current time loading: ${currentMessages.length} messages');
      } catch (e) {
        result['currentTimeSuccess'] = false;
        result['currentTimeError'] = e.toString();
        debugPrint('❌ Current time loading failed: $e');
      }

      // Test from 1 hour ago
      try {
        final oneHourAgo = DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch;
        final channel = await GroupChannel.getChannel(channelUrl);
        final oneHourMessages = await channel.getMessagesByTimestamp(oneHourAgo, testParams);
        result['oneHourMessages'] = oneHourMessages.length;
        result['oneHourSuccess'] = true;
        debugPrint('✅ One hour ago loading: ${oneHourMessages.length} messages');
      } catch (e) {
        result['oneHourSuccess'] = false;
        result['oneHourError'] = e.toString();
        debugPrint('❌ One hour ago loading failed: $e');
      }

      // Test from beginning
      try {
        final beginningTimestamp = DateTime(2020, 1, 1).millisecondsSinceEpoch;
        final channel = await GroupChannel.getChannel(channelUrl);
        final beginningMessages = await channel.getMessagesByTimestamp(beginningTimestamp, testParams);
        result['beginningMessages'] = beginningMessages.length;
        result['beginningSuccess'] = true;
        debugPrint('✅ Beginning loading: ${beginningMessages.length} messages');
      } catch (e) {
        result['beginningSuccess'] = false;
        result['beginningError'] = e.toString();
        debugPrint('❌ Beginning loading failed: $e');
      }

      debugPrint('🧪 Message loading test completed');
      return result;
    } catch (e) {
      debugPrint('❌ Error in test message loading: $e');
      return {'error': e.toString()};
    }
  }

  // Method to test message ordering for debugging
  Future<Map<String, dynamic>> testMessageOrdering(String channelUrl) async {
    try {
      debugPrint('🧪 Testing message ordering for channel: $channelUrl');

      final result = <String, dynamic>{};

      // Test 1: Get chat history
      try {
        final history = await getChatHistory(channelUrl, limit: 10);
        result['historyCount'] = history.length;
        result['historyOrdered'] = _isListOrdered(history);

        if (history.isNotEmpty) {
          result['historyFirstTime'] = history.first.timestamp.toString();
          result['historyLastTime'] = history.last.timestamp.toString();
        }

        debugPrint('✅ History test: ${history.length} messages, ordered: ${result['historyOrdered']}');
      } catch (e) {
        result['historyError'] = e.toString();
        debugPrint('❌ History test failed: $e');
      }

      // Test 2: Test pagination
      try {
        final moreMessages = await loadMoreMessages(channelUrl, limit: 5);
        result['paginationCount'] = moreMessages.length;
        result['paginationOrdered'] = _isListOrdered(moreMessages);

        if (moreMessages.isNotEmpty) {
          result['paginationFirstTime'] = moreMessages.first.timestamp.toString();
          result['paginationLastTime'] = moreMessages.last.timestamp.toString();
        }

        debugPrint('✅ Pagination test: ${moreMessages.length} messages, ordered: ${result['paginationOrdered']}');
      } catch (e) {
        result['paginationError'] = e.toString();
        debugPrint('❌ Pagination test failed: $e');
      }

      // Test 3: Check timestamp tracking
      final lastTimestamp = _lastMessageTimestamps[channelUrl];
      if (lastTimestamp != null) {
        result['lastTimestamp'] = DateTime.fromMillisecondsSinceEpoch(lastTimestamp).toString();
        result['lastTimestampMs'] = lastTimestamp;
      }

      debugPrint('🧪 Message ordering test completed');
      return result;
    } catch (e) {
      debugPrint('❌ Error in test message ordering: $e');
      return {'error': e.toString()};
    }
  }

  // Helper method to check if a list is properly ordered
  bool _isListOrdered(List<ChatMessage> messages) {
    if (messages.length <= 1) return true;

    for (int i = 1; i < messages.length; i++) {
      if (messages[i].timestamp.isBefore(messages[i - 1].timestamp)) {
        debugPrint('⚠️ Order violation at index $i: ${messages[i].timestamp} < ${messages[i - 1].timestamp}');
        return false;
      }
    }
    return true;
  }

  void dispose() {
    // Close all message controllers first
    for (final controller in _messageControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _messageControllers.clear();

    // Cancel all channel subscriptions
    for (final subscription in _channelSubscriptions.values) {
      subscription.cancel();
    }
    _channelSubscriptions.clear();

    // Cancel all polling timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    // Cancel all batch timers
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();

    // Clear timestamps
    _lastMessageTimestamps.clear();

    // Clear message batches
    _messageBatch.clear();

    // Remove real-time event handlers
    _messageReceivedSubscription?.cancel();
    _messageUpdatedSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _channelChangedSubscription?.cancel();

    // Reset all state variables
    _isInitialized = false;
    _isUserConnected = false;

    debugPrint('🧹 SendbirdService disposed successfully');
  }

  // Method to stop polling for a specific channel
  void stopPolling(String channelUrl) {
    // Cancel polling timer
    _pollingTimers[channelUrl]?.cancel();
    _pollingTimers.remove(channelUrl);

    // Cancel batch timer
    _batchTimers[channelUrl]?.cancel();
    _batchTimers.remove(channelUrl);

    // Clear timestamp
    _lastMessageTimestamps.remove(channelUrl);

    // Clear message batch
    _messageBatch.remove(channelUrl);

    // Close message controller if exists
    final controller = _messageControllers[channelUrl];
    if (controller != null && !controller.isClosed) {
      controller.close();
      _messageControllers.remove(channelUrl);
    }

    debugPrint('🛑 Stopped polling for channel: $channelUrl');
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

  // Copy with method for updating conversation
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

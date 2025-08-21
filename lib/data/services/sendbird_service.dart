import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import '../../controller/auth_controller.dart';
import '../responses/sendbird_response.dart';

class _SendbirdChannelHandler extends GroupChannelHandler {
  final SendbirdService _service;

  _SendbirdChannelHandler(this._service);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    debugPrint('📨 Message received in channel: ${channel.channelUrl}');
    debugPrint('📨 Message ID: ${message.messageId}, Type: ${message.runtimeType}');

    try {
      if (message.messageId.toString().isEmpty) {
        debugPrint('⚠️ Skipping message with invalid ID');
        return;
      }

      final chatMessage = ChatMessage.fromSendbird(message);

      if (chatMessage.text.isEmpty && message is! UserMessage) {
        debugPrint('⚠️ Skipping non-text message');
        return;
      }

      _service._addMessageToStream(channel.channelUrl, chatMessage);

      _service._lastMessageTimestamps[channel.channelUrl] = message.createdAt;

      _service._processedMessageIds.add(message.messageId.toString());

      _service._cleanupProcessedMessageIds();

      debugPrint('✅ Message processed successfully: ${message.messageId} - "${chatMessage.text}"');
    } catch (e) {
      debugPrint('❌ Error processing received message: $e');
      debugPrint('❌ Message details - ID: ${message.messageId}, Type: ${message.runtimeType}');

      Future.delayed(Duration(seconds: 1), () {
        try {
          _service._setupChannelHandler();
        } catch (retryError) {
          debugPrint('❌ Failed to recover message handler: $retryError');
        }
      });
    }
  }
}

class SendbirdService {
  static SendbirdService? _instance;
  static SendbirdService get instance => _instance ??= SendbirdService._();

  SendbirdService._();

  static const String _applicationId = '76B840AB-32EE-4792-B6C7-98FC3101C9D7';

  static bool get _isValidApplicationId =>
      _applicationId.isNotEmpty && _applicationId.length == 36 && _applicationId.contains('-');

  static const int _pollingIntervalSeconds = 3;
  static const int _maxMessagesPerRequest = 50;
  static const int _batchSize = 20;
  static const int _maxBatchDelay = 200;

  bool _isInitialized = false;
  bool _isUserConnected = false;
  String? _currentHandlerId;

  final Map<String, StreamController<ChatMessage>> _messageControllers = {};
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, int> _lastMessageTimestamps = {};
  final Map<String, List<ChatMessage>> _messageBatch = {};
  final Map<String, Timer> _batchTimers = {};
  final Set<String> _processedMessageIds = <String>{};
  final Map<String, bool> _processingBatch = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!_isValidApplicationId) {
        throw Exception('Invalid Sendbird Application ID format');
      }

      debugPrint('🚀 Initializing Sendbird Chat SDK...');
      await SendbirdChat.init(appId: _applicationId);

      _isInitialized = true;
      debugPrint('✅ Sendbird Chat SDK initialized successfully!');
    } catch (e) {
      debugPrint('❌ Failed to initialize Sendbird: $e');
      rethrow;
    }
  }

  Future<bool> connectUser(String userId, String nickname) async {
    if (!_isInitialized) await initialize();

    try {
      if (_isUserConnected && SendbirdChat.currentUser?.userId == userId) {
        debugPrint('✅ User already connected: $userId');
        return true;
      }

      debugPrint('🔄 Connecting user: $userId...');
      await SendbirdChat.connect(userId, nickname: nickname);
      _isUserConnected = true;

      final currentUser = SendbirdChat.currentUser;
      debugPrint('✅ User connected: ${currentUser?.userId} (${currentUser?.nickname})');

      _setupChannelHandler();

      return true;
    } catch (e) {
      debugPrint('❌ Failed to connect user: $e');
      _isUserConnected = false;
      return false;
    }
  }

  void _setupChannelHandler() {
    try {
      if (_currentHandlerId != null) {
        try {
          SendbirdChat.removeChannelHandler(_currentHandlerId!);
          debugPrint('🗑️ Removed existing channel handler: $_currentHandlerId');
        } catch (e) {
          debugPrint('⚠️ Warning: Failed to remove existing handler: $e');
        }
      }

      _currentHandlerId = 'handler_${DateTime.now().millisecondsSinceEpoch}';

      final handler = _SendbirdChannelHandler(this);
      SendbirdChat.addChannelHandler(_currentHandlerId!, handler);

      debugPrint('✅ Message reception handler set up successfully with ID: $_currentHandlerId');
      debugPrint('🔍 Current user: ${SendbirdChat.currentUser?.userId}');
      debugPrint('🔍 Handler registered for real-time message reception');

      _verifyHandlerSetup();
    } catch (e) {
      debugPrint('❌ Failed to set up message reception handler: $e');
      _currentHandlerId = null;

      Future.delayed(Duration(seconds: 2), () {
        if (_isUserConnected && _isInitialized) {
          debugPrint('🔄 Retrying channel handler setup...');
          _setupChannelHandler();
        }
      });
    }
  }

  void _verifyHandlerSetup() {
    try {
      if (_currentHandlerId != null) {
        final currentUser = SendbirdChat.currentUser;
        if (currentUser != null) {
          debugPrint('✅ Handler verification successful - User: ${currentUser.userId}');
        } else {
          debugPrint('⚠️ Handler verification warning - No current user');
        }
      }
    } catch (e) {
      debugPrint('❌ Handler verification failed: $e');
    }
  }

  bool isMessageHandlerActive() {
    return _currentHandlerId != null;
  }

  void testMessageReception() {
    debugPrint('🧪 Testing message reception handler...');
    debugPrint('🔍 Handler ID: $_currentHandlerId');
    debugPrint('🔍 User connected: $_isUserConnected');
    debugPrint('🔍 Current user: ${SendbirdChat.currentUser?.userId}');

    if (_currentHandlerId != null) {
      debugPrint('✅ Message handler is active');
    } else {
      debugPrint('❌ Message handler is not active');
    }
  }

  void _cleanupProcessedMessageIds() {
    try {
      if (_processedMessageIds.length > 1000) {
        final cutoffTime = DateTime.now().subtract(Duration(hours: 24));
        _processedMessageIds.clear();
        debugPrint('🧹 Cleaned up processed message IDs');
      }
    } catch (e) {
      debugPrint('⚠️ Warning: Failed to cleanup processed message IDs: $e');
    }
  }

  Future<bool> ensureMessageHandler() async {
    try {
      if (_currentHandlerId == null || !_isUserConnected) {
        debugPrint('🔄 Message handler not active, attempting to reconnect...');
        final userId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';
        final name = Get.find<AuthenticationController>().currentUser?.name ?? '';

        if (userId.isNotEmpty) {
          final connected = await connectUser(userId, name);
          if (connected) {
            debugPrint('✅ Message handler re-established successfully');
            return true;
          }
        }
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('❌ Failed to ensure message handler: $e');
      return false;
    }
  }

  Future<bool> _ensureUserConnected() async {
    if (!_isUserConnected) {
      final userId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';
      final name = Get.find<AuthenticationController>().currentUser?.name ?? '';
      return await connectUser(userId, name);
    }
    return true;
  }

  Future<bool> checkAndRecoverConnection() async {
    try {
      if (!_isUserConnected) {
        debugPrint('🔄 Attempting to reconnect...');
        return await _ensureUserConnected();
      }

      final currentUser = SendbirdChat.currentUser;
      if (currentUser == null || currentUser.userId.isEmpty) {
        debugPrint('🔄 Current user invalid, reconnecting...');
        _isUserConnected = false;
        return await _ensureUserConnected();
      }

      return true;
    } catch (e) {
      debugPrint('❌ Connection recovery failed: $e');
      _isUserConnected = false;
      return false;
    }
  }

  Future<bool> forceReconnect() async {
    try {
      debugPrint('🔄 Force reconnecting...');
      _isUserConnected = false;

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
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return [];

    try {
      if (channelUrl.isEmpty) {
        debugPrint('❌ Channel URL is empty');
        return [];
      }

      debugPrint('📚 Loading chat history: $channelUrl (limit: $limit)');

      final channel = await _getOrCreateChannel(channelUrl);

      if (channel == null) {
        debugPrint('❌ Failed to get or create channel');
        return [];
      }

      final messages = await _loadMessagesWithStrategy(channel, limit);
      final chatMessages = _convertToChatMessages(messages);

      if (chatMessages.isNotEmpty) {
        _lastMessageTimestamps[channelUrl] = chatMessages.last.timestamp.millisecondsSinceEpoch;
        _sortMessages(chatMessages);
      }

      debugPrint('✅ Loaded ${chatMessages.length} messages');
      return chatMessages;
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
      return [];
    }
  }

  Future<GroupChannel?> _getOrCreateChannel(String channelUrl) async {
    try {
      return await GroupChannel.getChannel(channelUrl);
    } catch (e) {
      try {
        debugPrint('📝 Creating new channel: $channelUrl');
        final params = GroupChannelCreateParams()
          ..channelUrl = channelUrl
          ..name = 'Chat Channel';
        return await GroupChannel.createChannel(params);
      } catch (createError) {
        debugPrint('❌ Failed to create channel: $createError');
        return null;
      }
    }
  }

  Future<List<BaseMessage>> _loadMessagesWithStrategy(GroupChannel channel, int limit) async {
    final params = _createMessageParams(limit);

    try {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      var messages = await channel.getMessagesByTimestamp(currentTimestamp, params);

      final baseMessages = messages.whereType<BaseMessage>().toList();

      if (baseMessages.length < limit * 0.5) {
        final timeRanges = [Duration(minutes: 30), Duration(hours: 2), Duration(hours: 24)];

        for (final range in timeRanges) {
          final timestamp = DateTime.now().subtract(range).millisecondsSinceEpoch;
          final moreMessages = await channel.getMessagesByTimestamp(timestamp, params);

          final moreBaseMessages = moreMessages.whereType<BaseMessage>().toList();
          if (moreBaseMessages.length > baseMessages.length) {
            baseMessages.clear();
            baseMessages.addAll(moreBaseMessages);
            debugPrint('📚 Loaded ${baseMessages.length} messages from ${range.inHours}h ago');
          }

          if (baseMessages.length >= limit * 0.8) break;
        }
      }

      return baseMessages;
    } catch (e) {
      debugPrint('❌ Failed to load messages: $e');
      return [];
    }
  }

  MessageListParams _createMessageParams(int limit) {
    return MessageListParams()
      ..previousResultSize = limit
      ..reverse = false
      ..includeReactions = false
      ..includeThreadInfo = false
      ..includeParentMessageInfo = false
      ..includeMetaArray = false;
  }

  List<ChatMessage> _convertToChatMessages(List<BaseMessage> messages) {
    return messages.map((msg) => ChatMessage.fromSendbird(msg)).toList();
  }

  void _sortMessages(List<ChatMessage> messages) {
    if (messages.length > 1) {
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  Future<List<ChatMessage>> loadMoreMessages(String channelUrl, {int limit = 20}) async {
    if (!_isInitialized || !await _ensureUserConnected()) return [];

    try {
      final oldestTimestamp = _lastMessageTimestamps[channelUrl];
      if (oldestTimestamp == null) return [];

      final channel = await GroupChannel.getChannel(channelUrl);
      final params = _createMessageParams(limit);
      final olderMessages = await channel.getMessagesByTimestamp(oldestTimestamp, params);

      final baseMessages = olderMessages.whereType<BaseMessage>().toList();
      if (baseMessages.isEmpty) return [];

      final chatMessages = _convertToChatMessages(baseMessages);
      _sortMessages(chatMessages);

      if (chatMessages.isNotEmpty) {
        _lastMessageTimestamps[channelUrl] = chatMessages.first.timestamp.millisecondsSinceEpoch;
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
      if (channelUrl.isEmpty || text.trim().isEmpty) {
        throw Exception('Channel URL and message text cannot be empty');
      }

      debugPrint('📤 Sending message to: $channelUrl');
      final channel = await GroupChannel.getChannel(channelUrl);
      final params = UserMessageCreateParams(message: text.trim());
      final userMessage = channel.sendUserMessage(params);

      debugPrint('✅ Message sent: ${userMessage.messageId}');
      _lastMessageTimestamps[channelUrl] = userMessage.createdAt;

      _addMessageToStream(channelUrl, ChatMessage.fromSendbird(userMessage));
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
      throw _createErrorMessage(e);
    }
  }

  Exception _createErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('network')) return Exception('Network error. Please check your connection.');
    if (errorStr.contains('channel')) return Exception('Channel error. Please try again.');
    if (errorStr.contains('permission')) return Exception('Permission denied.');
    if (errorStr.contains('timeout')) return Exception('Request timeout. Please try again.');
    return Exception('Failed to send message');
  }

  Future<List<Conversation>> getConversations() async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return [];

    try {
      debugPrint('🔄 Loading conversations...');
      final query = GroupChannelListQuery()..limit = 20;
      final channels = await query.next();

      final groupChannels = channels.whereType<GroupChannel>().toList();
      final conversations = groupChannels.map((channel) => Conversation.fromSendbird(channel)).toList();
      conversations.sort((a, b) => _compareConversationTime(a, b));
      debugPrint('✅ Loaded ${conversations.length} conversations');
      return conversations;
    } catch (e) {
      debugPrint('❌ Failed to load conversations: $e');
      return [];
    }
  }

  int _compareConversationTime(Conversation a, Conversation b) {
    if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
    if (a.lastMessageTime == null) return 1;
    if (b.lastMessageTime == null) return -1;
    return b.lastMessageTime!.compareTo(a.lastMessageTime!);
  }

  Stream<ChatMessage> getMessageStream(String channelUrl) {
    if (!_isInitialized) initialize();

    if (!_messageControllers.containsKey(channelUrl)) {
      _messageControllers[channelUrl] = StreamController<ChatMessage>.broadcast();
      _setupPolling(channelUrl);
    }

    return _messageControllers[channelUrl]!.stream;
  }

  void _setupPolling(String channelUrl) async {
    try {
      _pollingTimers[channelUrl]?.cancel();
      final channel = await GroupChannel.getChannel(channelUrl);

      _pollingTimers[channelUrl] = Timer.periodic(
        Duration(seconds: _pollingIntervalSeconds),
        (timer) => _pollNewMessages(channelUrl, channel),
      );
    } catch (e) {
      debugPrint('❌ Failed to set up polling: $e');
    }
  }

  Future<void> _pollNewMessages(String channelUrl, GroupChannel channel) async {
    try {
      final controller = _messageControllers[channelUrl];
      if (controller == null || controller.isClosed || !controller.hasListener) {
        _stopPolling(channelUrl);
        return;
      }

      final lastTimestamp = _lastMessageTimestamps[channelUrl] ?? DateTime.now().millisecondsSinceEpoch;
      final params = _createMessageParams(_batchSize);
      final latestMessages = await channel.getMessagesByTimestamp(lastTimestamp, params);

      final baseMessages = latestMessages.whereType<BaseMessage>().toList();
      final newMessages = baseMessages.where((msg) => msg.createdAt > lastTimestamp).toList();

      if (newMessages.isNotEmpty) {
        _lastMessageTimestamps[channelUrl] = newMessages.first.createdAt;
        final chatMessages = _convertToChatMessages(newMessages);
        _addToBatch(channelUrl, chatMessages);
      }
    } catch (e) {
      debugPrint('❌ Error in polling: $e');
    }
  }

  void _addToBatch(String channelUrl, List<ChatMessage> messages) {
    if (!_messageBatch.containsKey(channelUrl)) {
      _messageBatch[channelUrl] = [];
    }

    if (_processingBatch[channelUrl] == true) {
      debugPrint('⚠️ Batch already processing for channel: $channelUrl, skipping...');
      return;
    }

    _messageBatch[channelUrl]!.addAll(messages);
    _batchTimers[channelUrl]?.cancel();

    _batchTimers[channelUrl] = Timer(Duration(milliseconds: _maxBatchDelay), () => _processBatch(channelUrl));
  }

  void _processBatch(String channelUrl) {
    try {
      if (_processingBatch[channelUrl] == true) {
        debugPrint('⚠️ Batch already processing for channel: $channelUrl');
        return;
      }
      _processingBatch[channelUrl] = true;

      final controller = _messageControllers[channelUrl];
      final batch = _messageBatch[channelUrl];

      if (controller == null || batch == null || batch.isEmpty) {
        _processingBatch[channelUrl] = false;
        return;
      }
      if (controller.isClosed || !controller.hasListener) {
        _cleanupChannel(channelUrl);
        _processingBatch[channelUrl] = false;
        return;
      }

      _sortMessages(batch);

      for (final message in batch) {
        if (!controller.isClosed && controller.hasListener) {
          controller.add(message);
        }
      }

      _messageBatch[channelUrl]!.clear();
      _batchTimers.remove(channelUrl);
      _processingBatch[channelUrl] = false;
    } catch (e) {
      debugPrint('❌ Error processing batch: $e');
      _processingBatch[channelUrl] = false;
      _cleanupChannel(channelUrl);
    }
  }

  void _addMessageToStream(String channelUrl, ChatMessage message) {
    final controller = _messageControllers[channelUrl];
    if (controller != null && !controller.isClosed && controller.hasListener) {
      controller.add(message);
    }
  }

  Future<String> createConversation(String title, {String? initialMessage}) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) throw Exception('User not connected');

    try {
      if (title.trim().isEmpty || title.trim().length > 100) {
        throw Exception('Invalid conversation title (1-100 characters)');
      }

      final currentUserId = SendbirdChat.currentUser?.userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }

      debugPrint('🆕 Creating conversation: $title');

      final params = GroupChannelCreateParams()
        ..name = title.trim()
        ..userIds = [currentUserId]
        ..isDistinct = false
        ..isPublic = false;

      final channel = await GroupChannel.createChannel(params);

      if (channel.channelUrl.isEmpty) {
        throw Exception('Failed to create channel');
      }

      _lastMessageTimestamps[channel.channelUrl] = DateTime.now().millisecondsSinceEpoch;

      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        try {
          await sendMessage(channel.channelUrl, initialMessage.trim());
        } catch (e) {
          debugPrint('⚠️ Failed to send initial message: $e');
        }
      }

      debugPrint('✅ Created conversation: ${channel.channelUrl}');
      return channel.channelUrl;
    } catch (e) {
      debugPrint('❌ Failed to create conversation: $e');
      rethrow;
    }
  }

  Future<void> joinChannel(String channelUrl) async {
    if (!_isInitialized) await initialize();
    if (!await _ensureUserConnected()) return;

    try {
      await GroupChannel.getChannel(channelUrl);
    } catch (e) {
      debugPrint('❌ Failed to join channel: $e');
      rethrow;
    }
  }

  void _stopPolling(String channelUrl) {
    _pollingTimers[channelUrl]?.cancel();
    _pollingTimers.remove(channelUrl);
  }

  void _cleanupChannel(String channelUrl) {
    _messageBatch.remove(channelUrl);
    _batchTimers.remove(channelUrl);
    _lastMessageTimestamps.remove(channelUrl);
    _processingBatch.remove(channelUrl);
  }

  void stopPolling(String channelUrl) {
    _stopPolling(channelUrl);
    _cleanupChannel(channelUrl);

    final controller = _messageControllers[channelUrl];
    if (controller != null && !controller.isClosed) {
      controller.close();
      _messageControllers.remove(channelUrl);
    }

    debugPrint('🛑 Stopped polling for channel: $channelUrl');
  }

  bool get isUserConnected => _isUserConnected;

  void dispose() {
    for (final controller in _messageControllers.values) {
      if (!controller.isClosed) controller.close();
    }
    _messageControllers.clear();

    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();

    _lastMessageTimestamps.clear();
    _messageBatch.clear();
    _processedMessageIds.clear();
    _processingBatch.clear();

    _isInitialized = false;
    _isUserConnected = false;

    debugPrint('🧹 SendbirdService disposed successfully');
  }
}

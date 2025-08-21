import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cfv_mobile/data/repositories/sendbird_repository.dart';
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/services/sendbird_service.dart';

class SendbirdController extends GetxController {
  final ISendbirdRepository _repository;
  final AuthenticationController _authController;

  // Observable variables
  final RxBool isInitialized = false.obs;
  final RxBool isUserConnected = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  final RxString currentConversationId = ''.obs;

  // Data
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final Rx<Conversation?> currentConversation = Rx<Conversation?>(null);

  // Streams and timers
  StreamSubscription<ChatMessage>? _messageSubscription;

  // Message tracking
  final Set<String> _processedMessageIds = <String>{};
  final Set<String> _optimisticMessageIds = <String>{};

  SendbirdController({ISendbirdRepository? repository, AuthenticationController? authController})
    : _repository = repository ?? SendbirdRepository(),
      _authController = authController ?? Get.find<AuthenticationController>();

  @override
  void onClose() {
    _disposeResources();
    super.onClose();
  }

  Future<void> initialize() async {
    try {
      isLoading.value = true;
      connectionStatus.value = 'Initializing...';

      await _repository.initialize();
      isInitialized.value = true;

      // Check if user is already connected
      if (_repository.isUserConnected) {
        isUserConnected.value = true;
        connectionStatus.value = 'Connected';
      } else {
        isUserConnected.value = false;
        connectionStatus.value = 'Not connected';
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize Sendbird: $e');
      isUserConnected.value = false;
      connectionStatus.value = 'Initialization failed: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> connectUser() async {
    try {
      final userId = _authController.currentUser?.accountId ?? '';
      final name = _authController.currentUser?.name ?? 'Người dùng';

      if (userId.isEmpty) {
        debugPrint('❌ User ID is empty');
        // Update status immediately
        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = false;
            connectionStatus.value = 'User ID is empty';
          }
        });
        return false;
      }

      // Update status to connecting
      Future.microtask(() {
        if (!isClosed) {
          connectionStatus.value = 'Connecting...';
        }
      });

      final connected = await _repository.connectUser(userId, name);

      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          isUserConnected.value = connected;
          connectionStatus.value = connected ? 'Connected' : 'Failed to connect';
        }
      });

      if (connected) {
        debugPrint('✅ User connected successfully: $userId ($name)');
      } else {
        debugPrint('❌ Failed to connect user: $userId');
      }

      return connected;
    } catch (e) {
      debugPrint('❌ Failed to connect user: $e');
      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          isUserConnected.value = false;
          connectionStatus.value = 'Error: $e';
        }
      });
      return false;
    }
  }

  Future<void> loadConversations() async {
    try {
      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          isLoading.value = true;
        }
      });

      debugPrint('🔄 Loading conversations...');
      final conversationList = await _repository.getConversations();

      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          conversations.value = conversationList;
          isLoading.value = false;
        }
      });

      debugPrint('✅ Successfully loaded ${conversationList.length} conversations');
    } catch (e) {
      debugPrint('❌ Failed to load conversations: $e');
      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          conversations.value = [];
          isLoading.value = false;
        }
      });
    }
  }

  Future<void> openConversation(Conversation conversation) async {
    try {
      // Clear existing conversation first
      _clearCurrentConversation();

      if (isClosed) return;

      if (conversation.id.isEmpty) {
        throw Exception('Conversation ID is empty');
      }

      // Ensure user is connected before opening conversation
      if (!isUserConnected.value) {
        final connected = await connectUser();
        if (!connected) {
          throw Exception('Failed to connect user before opening conversation');
        }
      }

      currentConversation.value = conversation;
      currentConversationId.value = conversation.id;

      // Try to join the channel first
      try {
        await _repository.joinChannel(conversation.id);
      } catch (e) {
        // Continue anyway, might be able to read messages
      }

      // Load chat history first
      await loadChatHistory(conversation.id);

      // Subscribe to messages after loading history
      if (!isClosed) {
        _subscribeToMessages(conversation.id);
      }
    } catch (e) {
      // Reset conversation state on error
      if (!isClosed) {
        _clearCurrentConversation();
      }
      rethrow;
    }
  }

  Future<void> loadChatHistory(String channelUrl) async {
    try {
      if (isClosed) return;

      if (channelUrl.isEmpty) {
        return;
      }

      isLoading.value = true;

      // Ensure user is connected before loading history
      if (!isUserConnected.value) {
        final connected = await connectUser();
        if (!connected || isClosed) {
          return;
        }
      }

      debugPrint('📚 Loading chat history for channel: $channelUrl');

      final history = await _repository.getChatHistory(channelUrl);

      // Check if controller is still active before updating state
      if (isClosed) return;

      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          if (history.isNotEmpty) {
            // Clear processed message IDs for new conversation
            _processedMessageIds.clear();

            // Add all messages to processed set
            for (final message in history) {
              _processedMessageIds.add(message.id);
            }

            // Update messages observable
            messages.value = List.from(history);

            debugPrint('📚 Loaded ${history.length} messages. Latest: ${history.last.timestamp}');
          } else {
            messages.value = [];
            _processedMessageIds.clear();
            debugPrint('📚 No messages found in history');
          }
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
      // Check if controller is still active before updating state
      if (isClosed) return;

      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          messages.value = [];
          _processedMessageIds.clear();
        }
      });
    } finally {
      // Check if controller is still active before updating state
      if (isClosed) return;

      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          isLoading.value = false;
        }
      });
    }
  }

  // Method to load more messages (pagination)
  Future<void> loadMoreMessages(String channelUrl, {int limit = 20}) async {
    try {
      if (messages.isEmpty || isClosed) {
        debugPrint('📚 No existing messages to load more from or controller closed');
        return;
      }

      debugPrint('📚 Loading more messages for: $channelUrl (limit: $limit)');

      final moreMessages = await _repository.loadMoreMessages(channelUrl, limit: limit);

      if (moreMessages.isNotEmpty && !isClosed) {
        // Use Future.microtask to avoid setState during build
        Future.microtask(() {
          if (!isClosed) {
            // Add older messages to the beginning of the list
            final updatedMessages = [...moreMessages, ...messages];

            // Add new message IDs to processed set
            for (final message in moreMessages) {
              _processedMessageIds.add(message.id);
            }

            // Messages are already in correct order from service (oldest first)
            // Double-check ordering to ensure chronological sequence
            updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            messages.value = updatedMessages;
            debugPrint('📚 Added ${moreMessages.length} older messages. Total: ${messages.length}');
            debugPrint('📚 Message order verified: ${messages.first.timestamp} to ${messages.last.timestamp}');
          }
        });
      } else {
        debugPrint('📚 No more messages to load');
      }
    } catch (e) {
      debugPrint('❌ Failed to load more messages: $e');
    }
  }

  void _subscribeToMessages(String channelUrl) {
    try {
      if (isClosed) return;

      // Cancel existing subscription
      _messageSubscription?.cancel();

      debugPrint('📡 Subscribing to messages for channel: $channelUrl');

      // Subscribe to new messages
      _messageSubscription = _repository
          .getMessageStream(channelUrl)
          .listen(
            (message) {
              if (isClosed) return;

              // Check if message already exists to avoid duplicates
              if (!_processedMessageIds.contains(message.id)) {
                // Add new message to processed set
                _processedMessageIds.add(message.id);

                // Check if controller is still active before updating state
                if (isClosed) return;

                // Add new message to list
                messages.add(message);

                // Remove any optimistic messages that might be duplicates
                _removeOptimisticDuplicates(message);

                // Sort messages by timestamp to maintain chronological order
                _sortMessages();

                debugPrint('📨 New message added: ${message.text} at ${message.timestamp}');
              } else {
                debugPrint('📨 Duplicate message ignored: ${message.id}');
              }

              // Update conversation last message
              if (currentConversation.value != null && !isClosed) {
                Future.microtask(() {
                  if (!isClosed) {
                    currentConversation.value = currentConversation.value!.copyWith(
                      lastMessage: message.text,
                      lastMessageTime: message.timestamp,
                    );
                  }
                });
              }
            },
            onError: (error) {
              debugPrint('❌ Message stream error: $error');
              // Attempt to resubscribe after error
              Future.delayed(Duration(seconds: 2), () {
                if (currentConversationId.value.isNotEmpty && !isClosed) {
                  debugPrint('🔄 Attempting to resubscribe to messages...');
                  _subscribeToMessages(currentConversationId.value);
                }
              });
            },
            onDone: () {
              debugPrint('📨 Message stream closed for channel: $channelUrl');
            },
          );

      debugPrint('✅ Successfully subscribed to messages for channel: $channelUrl');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to messages: $e');
    }
  }

  void _removeOptimisticDuplicates(ChatMessage realMessage) {
    // Remove optimistic messages that match the real message
    messages.removeWhere((msg) {
      if (msg.id.startsWith('temp_') && msg.text == realMessage.text && msg.isMe == realMessage.isMe) {
        _optimisticMessageIds.remove(msg.id);
        return true;
      }
      return false;
    });
  }

  void _sortMessages() {
    // Sort messages by timestamp (oldest first) to maintain chronological order
    if (messages.length > 1) {
      final beforeSort = messages.map((m) => '${m.timestamp}: ${m.text}').take(3).toList();
      debugPrint('📚 Before sorting: ${beforeSort.join(' | ')}');

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final afterSort = messages.map((m) => '${m.timestamp}: ${m.text}').take(3).toList();
      debugPrint('📚 After sorting: ${afterSort.join(' | ')}');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isSending.value || currentConversationId.value.isEmpty || isClosed) return;

    try {
      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        if (!isClosed) {
          isSending.value = true;
        }
      });

      // Create optimistic message with unique ID
      final optimisticMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode}',
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
        senderId: _authController.currentUser?.accountId,
        senderName: _authController.currentUser?.name,
      );

      // Add optimistic message to UI immediately
      Future.microtask(() {
        if (!isClosed) {
          messages.add(optimisticMessage);
          _optimisticMessageIds.add(optimisticMessage.id);
          // Sort messages after adding
          _sortMessages();
        }
      });

      // Send to server
      await _repository.sendMessage(currentConversationId.value, text);

      // Remove optimistic message after a short delay to let real message come through
      Future.delayed(Duration(milliseconds: 500), () {
        if (!isClosed) {
          Future.microtask(() {
            if (!isClosed) {
              // Only remove if it still exists (real message might not have come yet)
              if (_optimisticMessageIds.contains(optimisticMessage.id)) {
                messages.removeWhere((msg) => msg.id == optimisticMessage.id);
                _optimisticMessageIds.remove(optimisticMessage.id);
                debugPrint('📤 Removed optimistic message after real message sent');
              }
              isSending.value = false;
            }
          });
        }
      });

      // Update conversation last message
      if (currentConversation.value != null && !isClosed) {
        Future.microtask(() {
          if (!isClosed) {
            currentConversation.value = currentConversation.value!.copyWith(
              lastMessage: text,
              lastMessageTime: DateTime.now(),
            );
          }
        });
      }

      debugPrint('📤 Message sent successfully: $text');
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
      // Check if controller is still active before updating state
      if (isClosed) return;

      // Remove optimistic message on error
      Future.microtask(() {
        if (!isClosed) {
          messages.removeWhere((msg) => _optimisticMessageIds.contains(msg.id));
          _optimisticMessageIds.clear();
          isSending.value = false;
        }
      });
      rethrow;
    }
  }

  // Method to retry sending a failed message
  Future<void> retryMessage(String text) async {
    if (text.trim().isEmpty || isSending.value || currentConversationId.value.isEmpty || isClosed) return;

    try {
      debugPrint('🔄 Retrying message: $text');
      await sendMessage(text);
    } catch (e) {
      debugPrint('❌ Failed to retry message: $e');
      rethrow;
    }
  }

  // Method to check if a message is being sent
  bool isMessageBeingSent(String text) {
    return _optimisticMessageIds.any((id) => id.contains(text.hashCode.toString()));
  }

  // Method to check actual connection status and sync it
  Future<void> checkConnectionStatus() async {
    try {
      debugPrint('🔍 Checking actual connection status...');

      // Check repository connection status
      final repositoryConnected = _repository.isUserConnected;

      // Check if we need to update our state
      if (isUserConnected.value != repositoryConnected) {
        debugPrint(
          '🔄 Connection status mismatch detected. Repository: $repositoryConnected, Controller: ${isUserConnected.value}',
        );

        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = repositoryConnected;
            connectionStatus.value = repositoryConnected ? 'Connected' : 'Disconnected';
          }
        });
      } else {
        debugPrint('✅ Connection status is synchronized');
      }
    } catch (e) {
      debugPrint('❌ Error checking connection status: $e');
    }
  }

  // Method to force refresh messages
  Future<void> forceRefreshMessages() async {
    try {
      if (isClosed || currentConversationId.value.isEmpty) {
        return;
      }

      debugPrint('🔄 Force refreshing messages for channel: ${currentConversationId.value}');

      // Reload chat history to get latest messages
      await loadChatHistory(currentConversationId.value);

      // Also check for any very recent messages that might have been missed
      try {
        final veryRecentMessages = await _repository.loadMoreMessages(currentConversationId.value, limit: 5);
        if (veryRecentMessages.isNotEmpty && !isClosed) {
          Future.microtask(() {
            if (!isClosed) {
              // Add any new messages that weren't in the history
              final existingIds = messages.map((m) => m.id).toSet();
              final newMessages = veryRecentMessages.where((m) => !existingIds.contains(m.id)).toList();

              if (newMessages.isNotEmpty) {
                debugPrint('🔄 Found ${newMessages.length} additional recent messages');
                messages.addAll(newMessages);
                _sortMessages();

                // Add to processed set
                for (final message in newMessages) {
                  _processedMessageIds.add(message.id);
                }
              }
            }
          });
        }
      } catch (e) {
        debugPrint('⚠️ Error checking very recent messages: $e');
      }

      debugPrint('✅ Force refresh completed');
    } catch (e) {
      debugPrint('❌ Error in force refresh: $e');
    }
  }

  // Method to check and recover connection
  Future<bool> checkAndRecoverConnection() async {
    try {
      debugPrint('🔄 Checking connection status...');
      final isConnected = await _repository.checkAndRecoverConnection();

      if (isConnected) {
        debugPrint('✅ Connection recovered successfully');
        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = true;
            connectionStatus.value = 'Connected';
          }
        });
      } else {
        debugPrint('❌ Failed to recover connection');
        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = false;
            connectionStatus.value = 'Connection Failed';
          }
        });
      }

      return isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connection: $e');
      Future.microtask(() {
        if (!isClosed) {
          isUserConnected.value = false;
          connectionStatus.value = 'Error: $e';
        }
      });
      return false;
    }
  }

  // Method to force reconnect
  Future<bool> forceReconnect() async {
    try {
      debugPrint('🔄 Force reconnecting...');
      isLoading.value = true;

      final isConnected = await _repository.forceReconnect();

      if (isConnected) {
        debugPrint('✅ Force reconnect successful');
        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = true;
            connectionStatus.value = 'Connected';
          }
        });
      } else {
        debugPrint('❌ Force reconnect failed');
        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = false;
            connectionStatus.value = 'Reconnect Failed';
          }
        });
      }

      return isConnected;
    } catch (e) {
      debugPrint('❌ Error during force reconnect: $e');
      Future.microtask(() {
        if (!isClosed) {
          isUserConnected.value = false;
          connectionStatus.value = 'Error: $e';
        }
      });
      return false;
    } finally {
      Future.microtask(() {
        if (!isClosed) {
          isLoading.value = false;
        }
      });
    }
  }

  Future<Conversation> createNewConversation(String title, {String? initialMessage}) async {
    try {
      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        isLoading.value = true;
      });

      debugPrint('🆕 Creating new conversation: $title');

      // Ensure user is connected before creating conversation
      if (!isUserConnected.value) {
        debugPrint('⚠️ User not connected, attempting to connect first...');
        final connected = await connectUser();
        if (!connected) {
          throw Exception('Failed to connect user before creating conversation');
        }
      }

      final channelUrl = await _repository.createConversation(title, initialMessage: initialMessage);

      if (channelUrl.isEmpty) {
        throw Exception('Failed to create channel: empty channel URL returned');
      }

      final newConversation = Conversation(
        id: channelUrl,
        title: title,
        lastMessage: initialMessage,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isOnline: true,
      );

      // Add to conversations list
      Future.microtask(() {
        conversations.add(newConversation);
        isLoading.value = false;
      });

      debugPrint('✅ Created new conversation: $title');
      return newConversation;
    } catch (e) {
      debugPrint('❌ Failed to create conversation: $e');

      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        isLoading.value = false;
      });
      rethrow;
    }
  }

  void _clearCurrentConversation() {
    if (isClosed) return;

    _messageSubscription?.cancel();
    _messageSubscription = null;

    currentConversation.value = null;
    currentConversationId.value = '';
    messages.clear();
    _processedMessageIds.clear();
    _optimisticMessageIds.clear();
  }

  void clearCurrentConversation() {
    _clearCurrentConversation();
  }

  void stopPolling(String channelUrl) {
    if (isClosed) return;

    // Stop polling for the specified channel
    if (channelUrl == currentConversationId.value) {
      _clearCurrentConversation();
    }
    // Also stop polling in the repository
    _repository.stopPolling(channelUrl);
  }

  void _disposeResources() {
    // Cancel all subscriptions first
    _messageSubscription?.cancel();
    _messageSubscription = null;

    // Clear all observable values to prevent updates after dispose
    if (!isClosed) {
      messages.clear();
      conversations.clear();
      currentConversation.value = null;
      currentConversationId.value = '';

      // Clear tracking sets
      _processedMessageIds.clear();
      _optimisticMessageIds.clear();

      // Reset all states
      isInitialized.value = false;
      isUserConnected.value = false;
      isLoading.value = false;
      isSending.value = false;
      connectionStatus.value = 'Disposed';
    }

    // Dispose repository
    try {
      _repository.dispose();
    } catch (e) {
      // Ignore errors during dispose
    }
  }

  // Getters for UI
  bool get hasCurrentConversation => currentConversation.value != null;
  String get currentConversationTitle => currentConversation.value?.title ?? 'Cuộc trò chuyện';
  String? get currentConversationLastMessage => currentConversation.value?.lastMessage;
  DateTime? get currentConversationLastMessageTime => currentConversation.value?.lastMessageTime;
  bool get isCurrentConversationOnline => currentConversation.value?.isOnline ?? false;

  // Method to test message ordering for debugging
  Future<Map<String, dynamic>> testMessageOrdering(String channelUrl) async {
    try {
      debugPrint('🧪 Controller: Testing message ordering for channel: $channelUrl');

      final result = await _repository.testMessageOrdering(channelUrl);

      // Add controller-specific checks
      result['controllerMessagesCount'] = messages.length;
      result['controllerMessagesOrdered'] = _areMessagesOrdered();

      if (messages.isNotEmpty) {
        result['controllerFirstTime'] = messages.first.timestamp.toString();
        result['controllerLastTime'] = messages.last.timestamp.toString();
      }

      debugPrint('🧪 Controller test completed: ${result.toString()}');
      return result;
    } catch (e) {
      debugPrint('❌ Controller test failed: $e');
      return {'error': e.toString()};
    }
  }

  // Helper method to check if controller messages are ordered
  bool _areMessagesOrdered() {
    if (messages.length <= 1) return true;

    for (int i = 1; i < messages.length; i++) {
      if (messages[i].timestamp.isBefore(messages[i - 1].timestamp)) {
        debugPrint(
          '⚠️ Controller: Order violation at index $i: ${messages[i].timestamp} < ${messages[i - 1].timestamp}',
        );
        return false;
      }
    }
    return true;
  }

  // Method to ensure latest messages are displayed
  Future<void> ensureLatestMessages() async {
    try {
      if (isClosed || currentConversationId.value.isEmpty) {
        return;
      }

      debugPrint('🔍 Ensuring latest messages are displayed');

      // Check if we have messages
      if (messages.isEmpty) {
        debugPrint('🔍 No messages, loading chat history');
        await loadChatHistory(currentConversationId.value);
        return;
      }

      // Get the latest message timestamp we have
      final latestTimestamp = messages.last.timestamp.millisecondsSinceEpoch;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // If our latest message is more than 1 minute old, refresh
      if (currentTime - latestTimestamp > 60000) {
        // 1 minute
        debugPrint('🔍 Latest message is old (${currentTime - latestTimestamp}ms), refreshing');
        await forceRefreshMessages();
      } else {
        debugPrint('🔍 Latest message is recent (${currentTime - latestTimestamp}ms), no refresh needed');
      }
    } catch (e) {
      debugPrint('❌ Error ensuring latest messages: $e');
    }
  }

  // Method to get message count and latest message info
  Map<String, dynamic> getMessageInfo() {
    if (messages.isEmpty) {
      return {'count': 0, 'hasMessages': false, 'latestMessage': null, 'latestTimestamp': null};
    }

    final latestMessage = messages.last;
    return {
      'count': messages.length,
      'hasMessages': true,
      'latestMessage': latestMessage.text,
      'latestTimestamp': latestMessage.timestamp.toString(),
      'latestMessageId': latestMessage.id,
      'isLatestFromMe': latestMessage.isMe,
    };
  }
}

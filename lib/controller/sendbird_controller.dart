import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cfv_mobile/data/repositories/sendbird_repository.dart';
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/responses/sendbird_response.dart';

class SendbirdController extends GetxController {
  final ISendbirdRepository _repository;
  final AuthenticationController _authController;

  final RxBool isInitialized = false.obs;
  final RxBool isUserConnected = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  final RxString currentConversationId = ''.obs;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final Rx<Conversation?> currentConversation = Rx<Conversation?>(null);

  StreamSubscription<ChatMessage>? _messageSubscription;

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
        Future.microtask(() {
          if (!isClosed) {
            isUserConnected.value = false;
            connectionStatus.value = 'User ID is empty';
          }
        });
        return false;
      }

      Future.microtask(() {
        if (!isClosed) {
          connectionStatus.value = 'Connecting...';
        }
      });

      final connected = await _repository.connectUser(userId, name);

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
      Future.microtask(() {
        if (!isClosed) {
          isLoading.value = true;
        }
      });

      debugPrint('🔄 Loading conversations...');
      final conversationList = await _repository.getConversations();

      Future.microtask(() {
        if (!isClosed) {
          conversations.value = conversationList;
          isLoading.value = false;
        }
      });

      debugPrint('✅ Successfully loaded ${conversationList.length} conversations');
    } catch (e) {
      debugPrint('❌ Failed to load conversations: $e');
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
      _clearCurrentConversation();

      if (isClosed) return;

      if (conversation.id.isEmpty) {
        throw Exception('Conversation ID is empty');
      }

      if (!isUserConnected.value) {
        final connected = await connectUser();
        if (!connected) {
          throw Exception('Failed to connect user before opening conversation');
        }
      }

      currentConversation.value = conversation;
      currentConversationId.value = conversation.id;

      try {
        await _repository.joinChannel(conversation.id);
      } catch (e) {}

      await loadChatHistory(conversation.id);

      if (!isClosed) {
        _subscribeToMessages(conversation.id);
      }
    } catch (e) {
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

      if (!isUserConnected.value) {
        final connected = await connectUser();
        if (!connected || isClosed) {
          return;
        }
      }

      debugPrint('📚 Loading chat history for channel: $channelUrl');

      final history = await _repository.getChatHistory(channelUrl);

      if (isClosed) return;

      Future.microtask(() {
        if (!isClosed) {
          if (history.isNotEmpty) {
            _processedMessageIds.clear();

            for (final message in history) {
              _processedMessageIds.add(message.id);
            }

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
      if (isClosed) return;

      Future.microtask(() {
        if (!isClosed) {
          messages.value = [];
          _processedMessageIds.clear();
        }
      });
    } finally {
      if (isClosed) return;

      Future.microtask(() {
        if (!isClosed) {
          isLoading.value = false;
        }
      });
    }
  }

  Future<void> loadMoreMessages(String channelUrl, {int limit = 20}) async {
    try {
      if (messages.isEmpty || isClosed) {
        debugPrint('📚 No existing messages to load more from or controller closed');
        return;
      }

      debugPrint('📚 Loading more messages for: $channelUrl (limit: $limit)');

      final moreMessages = await _repository.loadMoreMessages(channelUrl, limit: limit);

      if (moreMessages.isNotEmpty && !isClosed) {
        Future.microtask(() {
          if (!isClosed) {
            final updatedMessages = [...moreMessages, ...messages];

            for (final message in moreMessages) {
              _processedMessageIds.add(message.id);
            }

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

      _messageSubscription?.cancel();

      debugPrint('📡 Subscribing to messages for channel: $channelUrl');

      _messageSubscription = _repository
          .getMessageStream(channelUrl)
          .listen(
            (message) {
              if (isClosed) return;

              if (!_processedMessageIds.contains(message.id)) {
                _processedMessageIds.add(message.id);

                if (isClosed) return;

                messages.add(message);

                _removeOptimisticDuplicates(message);

                _sortMessages();

                debugPrint('📨 New message added: ${message.text} at ${message.timestamp}');
              } else {
                debugPrint('📨 Duplicate message ignored: ${message.id}');
              }

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
    messages.removeWhere((msg) {
      if (msg.id.startsWith('temp_') && msg.text == realMessage.text && msg.isMe == realMessage.isMe) {
        _optimisticMessageIds.remove(msg.id);
        return true;
      }
      return false;
    });
  }

  void _sortMessages() {
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
      Future.microtask(() {
        if (!isClosed) {
          isSending.value = true;
        }
      });

      final optimisticMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode}',
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
        senderId: _authController.currentUser?.accountId,
        senderName: _authController.currentUser?.name,
      );

      Future.microtask(() {
        if (!isClosed) {
          messages.add(optimisticMessage);
          _optimisticMessageIds.add(optimisticMessage.id);
          _sortMessages();
        }
      });

      await _repository.sendMessage(currentConversationId.value, text);

      Future.delayed(Duration(milliseconds: 500), () {
        if (!isClosed) {
          Future.microtask(() {
            if (!isClosed) {
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
      if (isClosed) return;

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

  bool isMessageBeingSent(String text) {
    return _optimisticMessageIds.any((id) => id.contains(text.hashCode.toString()));
  }

  Future<void> checkConnectionStatus() async {
    try {
      debugPrint('🔍 Checking actual connection status...');

      final repositoryConnected = _repository.isUserConnected;

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

  Future<void> forceRefreshMessages() async {
    try {
      if (isClosed || currentConversationId.value.isEmpty) {
        return;
      }

      debugPrint('🔄 Force refreshing messages for channel: ${currentConversationId.value}');

      await loadChatHistory(currentConversationId.value);

      try {
        final veryRecentMessages = await _repository.loadMoreMessages(currentConversationId.value, limit: 5);
        if (veryRecentMessages.isNotEmpty && !isClosed) {
          Future.microtask(() {
            if (!isClosed) {
              final existingIds = messages.map((m) => m.id).toSet();
              final newMessages = veryRecentMessages.where((m) => !existingIds.contains(m.id)).toList();

              if (newMessages.isNotEmpty) {
                debugPrint('🔄 Found ${newMessages.length} additional recent messages');
                messages.addAll(newMessages);
                _sortMessages();

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
      Future.microtask(() {
        isLoading.value = true;
      });

      debugPrint('🆕 Creating new conversation: $title');

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

      Future.microtask(() {
        conversations.add(newConversation);
        isLoading.value = false;
      });

      debugPrint('✅ Created new conversation: $title');
      return newConversation;
    } catch (e) {
      debugPrint('❌ Failed to create conversation: $e');

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

    if (channelUrl == currentConversationId.value) {
      _clearCurrentConversation();
    }
    _repository.stopPolling(channelUrl);
  }

  void _disposeResources() {
    _messageSubscription?.cancel();
    _messageSubscription = null;

    if (!isClosed) {
      messages.clear();
      conversations.clear();
      currentConversation.value = null;
      currentConversationId.value = '';

      _processedMessageIds.clear();
      _optimisticMessageIds.clear();

      isInitialized.value = false;
      isUserConnected.value = false;
      isLoading.value = false;
      isSending.value = false;
      connectionStatus.value = 'Disposed';
    }

    try {
      _repository.dispose();
    } catch (e) {}
  }

  bool get hasCurrentConversation => currentConversation.value != null;
  String get currentConversationTitle => currentConversation.value?.title ?? 'Cuộc trò chuyện';
  String? get currentConversationLastMessage => currentConversation.value?.lastMessage;
  DateTime? get currentConversationLastMessageTime => currentConversation.value?.lastMessageTime;
  bool get isCurrentConversationOnline => currentConversation.value?.isOnline ?? false;

  Future<void> ensureLatestMessages() async {
    try {
      if (isClosed || currentConversationId.value.isEmpty) {
        return;
      }

      debugPrint('🔍 Ensuring latest messages are displayed');

      if (messages.isEmpty) {
        debugPrint('🔍 No messages, loading chat history');
        await loadChatHistory(currentConversationId.value);
        return;
      }

      final latestTimestamp = messages.last.timestamp.millisecondsSinceEpoch;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - latestTimestamp > 60000) {
        debugPrint('🔍 Latest message is old (${currentTime - latestTimestamp}ms), refreshing');
        await forceRefreshMessages();
      } else {
        debugPrint('🔍 Latest message is recent (${currentTime - latestTimestamp}ms), no refresh needed');
      }
    } catch (e) {
      debugPrint('❌ Error ensuring latest messages: $e');
    }
  }

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

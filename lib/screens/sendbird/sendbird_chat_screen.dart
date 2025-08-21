import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/controller/sendbird_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:cfv_mobile/data/services/sendbird_service.dart';
import 'dart:async';

import '../../data/responses/sendbird_response.dart'; // Added for Timer

class SendbirdChatScreen extends StatefulWidget {
  final String? conversationId;
  final String? initialMessage;
  final Conversation? conversation;

  const SendbirdChatScreen({super.key, this.conversationId, this.initialMessage, this.conversation});

  @override
  State<SendbirdChatScreen> createState() => _SendbirdChatScreenState();
}

class _SendbirdChatScreenState extends State<SendbirdChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SendbirdController _sendbirdController;

  // Local state for better UX
  bool _isInitializing = true;
  String? _errorMessage;
  Timer? _autoScrollTimer;
  bool _isScrollingToBottom = false;

  // Local state to avoid Obx() issues
  bool _isUserConnected = false;
  bool _isSending = false;
  bool _isLoading = false;
  List<ChatMessage> _messages = [];
  String _currentConversationTitle = 'Cuộc trò chuyện';
  String? _currentConversationLastMessage;
  bool _hasCurrentConversation = false;

  @override
  void initState() {
    super.initState();
    _sendbirdController = Get.find<SendbirdController>();

    // Initialize connection status from controller
    _isUserConnected = _sendbirdController.isUserConnected.value;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeChat();

      // Auto-scroll to bottom when new messages arrive
      _setupAutoScroll();

      // Listen to controller changes
      _setupControllerListeners();
    });
  }

  void _setupControllerListeners() {
    // Listen to connection status with better error handling
    _sendbirdController.isUserConnected.listen((connected) {
      if (mounted) {
        setState(() {
          _isUserConnected = connected;
        });
      }
    });

    // Listen to connection status string for debugging
    _sendbirdController.connectionStatus.listen((status) {
      if (mounted) {
        // debugPrint('🔗 Connection status: $status');
      }
    });

    // Listen to sending status
    _sendbirdController.isSending.listen((sending) {
      if (mounted) {
        setState(() {
          _isSending = sending;
        });
      }
    });

    // Listen to loading status
    _sendbirdController.isLoading.listen((loading) {
      if (mounted) {
        setState(() {
          _isLoading = loading;
        });
      }
    });

    // Listen to messages with optimized handling
    _sendbirdController.messages.listen((messages) {
      if (mounted) {
        // Always update messages to ensure UI is in sync
        setState(() {
          _messages = List.from(messages);
        });

        // Verify message order for debugging
        if (messages.length > 1) {
          final firstTime = messages.first.timestamp;
          final lastTime = messages.last.timestamp;
          debugPrint('📱 UI: Messages updated. Range: $firstTime to $lastTime. Count: ${messages.length}');

          // Check if messages are in correct order
          if (firstTime.isAfter(lastTime)) {
            debugPrint('⚠️ UI: Messages appear to be in wrong order!');
          }
        }

        // Auto-scroll to bottom for new messages (not user scrolling)
        if (!_isScrollingToBottom && messages.isNotEmpty) {
          // Check if the last message is new (not an optimistic message)
          final lastMessage = messages.last;
          if (!lastMessage.id.startsWith('temp_')) {
            _scrollToBottom();
          }
        }
      }
    });

    // Listen to current conversation
    _sendbirdController.currentConversation.listen((conversation) {
      if (mounted && conversation != null) {
        setState(() {
          _hasCurrentConversation = true;
          _currentConversationTitle = conversation.title;
          _currentConversationLastMessage = conversation.lastMessage;
        });
      }
    });
  }

  void _setupAutoScroll() {
    // Remove the periodic timer as it's not efficient
    // Instead, we'll scroll when new messages arrive
  }

  Future<void> _initializeChat() async {
    try {
      if (!mounted) return;

      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Check connection status first
      if (!_sendbirdController.isUserConnected.value) {
        final connected = await _sendbirdController.connectUser();
        if (mounted) {
          setState(() {
            _isUserConnected = connected;
          });
        }
      } else {
        // Double-check connection status to ensure synchronization
        await _sendbirdController.checkConnectionStatus();
        if (mounted) {
          setState(() {
            _isUserConnected = _sendbirdController.isUserConnected.value;
          });
        }
      }

      // Priority: conversation object > conversationId > create new
      if (widget.conversation != null) {
        await _sendbirdController.openConversation(widget.conversation!);
      } else if (widget.conversationId != null) {
        // Create a temporary conversation object
        final tempConversation = Conversation(
          id: widget.conversationId!,
          title: 'Cuộc trò chuyện',
          lastMessage: null,
          lastMessageTime: null,
        );
        await _sendbirdController.openConversation(tempConversation);
      } else {
        // Create new conversation
        final newConversation = await _sendbirdController.createNewConversation(
          'Cuộc trò chuyện mới',
          initialMessage: widget.initialMessage,
        );
        await _sendbirdController.openConversation(newConversation);
      }

      // Scroll to bottom after loading
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Không thể kết nối chat: $e';
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể kết nối chat: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(label: 'Thử lại', textColor: Colors.white, onPressed: _retryInitialization),
          ),
        );
      }
    }
  }

  Future<void> _retryInitialization() async {
    if (!mounted) return;

    setState(() {
      _errorMessage = null;
    });
    await _initializeChat();
  }

  void _scrollToBottom() {
    if (!mounted || _isScrollingToBottom) return;

    _isScrollingToBottom = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController
            .animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            )
            .then((_) {
              if (mounted) {
                _isScrollingToBottom = false;
              }
            });
      } else {
        if (mounted) {
          _isScrollingToBottom = false;
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || !mounted) return;

    try {
      // Clear input immediately for better UX
      _messageController.clear();

      // Send message
      await _sendbirdController.sendMessage(text);

      // Scroll to bottom after sending
      if (mounted) {
        _scrollToBottom();
      }
    } catch (e) {
      // Restore message text on error
      if (mounted) {
        _messageController.text = text;

        // Show error message with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi tin nhắn: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(label: 'Thử lại', textColor: Colors.white, onPressed: () => _retryMessage(text)),
          ),
        );
      }
    }
  }

  Future<void> _retryMessage(String text) async {
    if (!mounted) return;

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đang thử lại...'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
      );

      // Retry sending the message
      await _sendbirdController.retryMessage(text);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi tin nhắn thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Scroll to bottom after sending
      if (mounted) {
        _scrollToBottom();
      }
    } catch (e) {
      // Show error message again
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vẫn không thể gửi tin nhắn: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _shouldShowMessageHeader(ChatMessage previousMessage, ChatMessage currentMessage) {
    // Show header if messages are from different senders or different days
    if (previousMessage.isMe != currentMessage.isMe) return true;

    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );
    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );

    return previousDate.isBefore(currentDate);
  }

  Widget _buildDateSeparator(DateTime timestamp) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Text(
              _formatDate(timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Hôm nay';
    } else if (messageDate == yesterday) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildMessageList() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50))),
            SizedBox(height: 16),
            Text('Đang kết nối...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 40),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _retryInitialization,
              child: Text('Thử lại', style: TextStyle(fontSize: 16, color: Color(0xFF4CAF50))),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
              child: Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            Text(
              'Bắt đầu cuộc trò chuyện',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              _currentConversationTitle.contains('AI') ? 'Hỏi tôi bất cứ điều gì về sản phẩm' : 'Gửi tin nhắn đầu tiên',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: _messages.length + 1, // +1 for loading indicator
      itemBuilder: (context, index) {
        // Show loading indicator at the top for pagination
        if (index == 0) {
          return _buildLoadMoreButton();
        }

        final messageIndex = index - 1;
        final message = _messages[messageIndex];
        final isFirstInGroup = messageIndex == 0 || _shouldShowMessageHeader(_messages[messageIndex - 1], message);

        return Column(
          children: [
            // Date separator
            if (isFirstInGroup && messageIndex > 0) _buildDateSeparator(message.timestamp),

            // Message bubble
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Center(
        child: TextButton.icon(
          onPressed: _isLoading ? null : _loadMoreMessages,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                )
              : Icon(Icons.history, size: 16, color: Color(0xFF4CAF50)),
          label: Text(
            _isLoading ? 'Đang tải...' : 'Tải tin nhắn cũ hơn',
            style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14),
          ),
        ),
      ),
    );
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || !_hasCurrentConversation || !mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Remember current scroll position and first visible message
      final currentScrollPosition = _scrollController.position.pixels;
      final currentMaxScroll = _scrollController.position.maxScrollExtent;

      // Get the first visible message index for better scroll restoration
      int firstVisibleIndex = 0;
      if (_scrollController.hasClients) {
        firstVisibleIndex = (_scrollController.position.pixels / 100).floor(); // Approximate
      }

      debugPrint('📚 Loading more messages. Current scroll: $currentScrollPosition, First visible: $firstVisibleIndex');

      // Load more messages
      await _sendbirdController.loadMoreMessages(_sendbirdController.currentConversationId.value, limit: 20);

      // Restore scroll position after loading
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            final newMaxScroll = _scrollController.position.maxScrollExtent;
            final scrollOffset = newMaxScroll - currentMaxScroll;

            if (scrollOffset > 0) {
              // Calculate new position to keep the same content visible
              final newPosition = currentScrollPosition + scrollOffset;
              debugPrint('📚 Restoring scroll position: $currentScrollPosition -> $newPosition');

              // Use jumpTo for immediate positioning to prevent visual jumping
              _scrollController.jumpTo(newPosition);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading more messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải tin nhắn cũ hơn: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 24, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 16),
                    // Conversation Avatar with connection status
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chat, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentConversationTitle,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              // Connection status indicator
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isUserConnected ? Color(0xFF4CAF50) : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              if (!_isUserConnected)
                                Text(
                                  _sendbirdController.connectionStatus.value == 'Connecting...'
                                      ? "Đang kết nối..."
                                      : "Mất kết nối",
                                  style: TextStyle(fontSize: 12, color: Colors.red),
                                )
                              else
                                Text(
                                  _currentConversationLastMessage ?? "Bắt đầu cuộc trò chuyện",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Connection retry button
                    if (!_isUserConnected)
                      IconButton(
                        icon: Icon(Icons.refresh, size: 20, color: Colors.red),
                        onPressed: () async {
                          try {
                            await _sendbirdController.forceReconnect();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Không thể kết nối lại: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        tooltip: 'Thử kết nối lại',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Conversation info header
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isOptimistic = message.id.startsWith('temp_');

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _sendbirdController.currentConversationTitle.contains('AI') ? Icons.smart_toy : Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender name for group chats
                if (!message.isMe && message.senderName != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      message.senderName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? (isOptimistic ? Color(0xFF81C784).withValues(alpha: 0.8) : Color(0xFF4CAF50))
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                      bottomRight: Radius.circular(message.isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isOptimistic ? 0.03 : 0.05),
                        blurRadius: isOptimistic ? 3 : 5,
                        offset: Offset(0, isOptimistic ? 1 : 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: message.isMe ? Colors.white : Colors.black87,
                            height: 1.4,
                            fontStyle: isOptimistic ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                      if (isOptimistic) ...[
                        SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.timeString,
                      style: TextStyle(
                        fontSize: 11,
                        color: isOptimistic ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: isOptimistic ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (message.isMe) ...[
                      SizedBox(width: 4),
                      Icon(
                        isOptimistic ? Icons.schedule : Icons.done_all,
                        size: 12,
                        color: isOptimistic ? Colors.grey[400] : Color(0xFF4CAF50),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (message.isMe) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isOptimistic ? Colors.grey[300] : Color(0xFF81C4E8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          // Message input row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: _isUserConnected ? Colors.grey[300]! : Colors.red[200]!, width: 1),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _isUserConnected ? 'Nhập tin nhắn...' : 'Đang kết nối...',
                      hintStyle: TextStyle(color: _isUserConnected ? Colors.grey[500] : Colors.red[300]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onChanged: (text) {
                      // Typing logic removed
                    },
                    onSubmitted: (_) => _sendMessage(),
                    enabled: _isUserConnected && !_isSending,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: (_isSending || !_isUserConnected) ? Colors.grey[400] : Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: (_isSending || !_isUserConnected) ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel all timers first
    _autoScrollTimer?.cancel();

    // Stop polling for current conversation
    if (_hasCurrentConversation && _sendbirdController.currentConversationId.value.isNotEmpty) {
      try {
        _sendbirdController.stopPolling(_sendbirdController.currentConversationId.value);
      } catch (e) {
        // Ignore errors during dispose
      }
    }

    // Clear all local state
    _messages.clear();
    _isUserConnected = false;
    _isSending = false;
    _isLoading = false;
    _hasCurrentConversation = false;

    // Dispose controllers
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}

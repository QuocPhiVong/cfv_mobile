import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:cfv_mobile/data/services/sendbird_service.dart';
import 'package:get/get.dart';

class SendbirdChatScreen extends StatefulWidget {
  final String? conversationId;
  final String? initialMessage;

  const SendbirdChatScreen({super.key, this.conversationId, this.initialMessage});

  @override
  State<SendbirdChatScreen> createState() => _SendbirdChatScreenState();
}

class _SendbirdChatScreenState extends State<SendbirdChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SendbirdService _SendbirdService = SendbirdService.instance;

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String _conversationId = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _SendbirdService.initialize();

      // Connect user (using a simple user ID for demo)
      final userId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';
      final name = Get.find<AuthenticationController>().currentUser?.name ?? 'Người dùng';
      final connected = await _SendbirdService.connectUser(userId, name);

      if (!connected) {
        throw Exception('Không thể kết nối người dùng');
      }

      if (widget.conversationId != null) {
        _conversationId = widget.conversationId!;
        final history = await _SendbirdService.getChatHistory(_conversationId);
        setState(() {
          _messages = history;
          _isLoading = false;
        });
      } else {
        // Create new conversation
        _conversationId = await _SendbirdService.createConversation(
          'Chat với Sendbird AI',
          initialMessage: widget.initialMessage,
        );
        setState(() {
          _isLoading = false;
        });
      }

      // Listen to new messages
      _SendbirdService.getMessageStream(_conversationId).listen((message) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể kết nối chat: $e')));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _SendbirdService.sendMessage(_conversationId, text);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể gửi tin nhắn: $e')));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
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
                    // Sendbird Avatar
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
                      child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sendbird AI",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Text("Trợ lý ảo thông minh", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
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
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50))),
                        SizedBox(height: 16),
                        Text('Đang kết nối...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  )
                : _messages.isEmpty
                ? Center(
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
                          'Hỏi tôi bất cứ điều gì về sản phẩm',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
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
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isMe ? Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                      bottomRight: Radius.circular(message.isMe ? 4 : 20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(fontSize: 14, color: message.isMe ? Colors.white : Colors.black87, height: 1.4),
                  ),
                ),
                SizedBox(height: 4),
                Text(message.timeString, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          if (message.isMe) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: Color(0xFF81C4E8), shape: BoxShape.circle),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(color: _isSending ? Colors.grey[400] : Color(0xFF4CAF50), shape: BoxShape.circle),
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
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

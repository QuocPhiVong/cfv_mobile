import 'package:cfv_mobile/screens/sendbird/index.dart';
import 'package:cfv_mobile/data/services/sendbird_service.dart';
import 'package:flutter/material.dart';

class SendbirdConversationListScreen extends StatefulWidget {
  const SendbirdConversationListScreen({super.key});

  @override
  State<SendbirdConversationListScreen> createState() => _SendbirdConversationListScreenState();
}

class _SendbirdConversationListScreenState extends State<SendbirdConversationListScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  final SendbirdService _sendbirdService = SendbirdService.instance;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Initialize Sendbird service if needed
      await _sendbirdService.initialize();

      // Get real conversations from Sendbird
      final conversations = await _sendbirdService.getConversations();

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải danh sách trò chuyện: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  Future<void> _startNewChat() async {
    try {
      // Show dialog to input conversation title
      final title = await _showNewChatDialog();
      if (title != null && title.isNotEmpty) {
        // Create new conversation
        final channelUrl = await _sendbirdService.createConversation(title);

        // Navigate to chat screen with new channel
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SendbirdChatScreen(conversationId: channelUrl)),
          );
        }

        // Refresh conversations list
        await _loadConversations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tạo cuộc trò chuyện mới: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<String?> _showNewChatDialog() async {
    String title = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cuộc trò chuyện mới'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Nhập tiêu đề cuộc trò chuyện', border: OutlineInputBorder()),
            onChanged: (value) {
              title = value;
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(title), child: Text('Tạo')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Tin nhắn",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                    Icon(Icons.search, size: 24, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // New Chat Button
          Container(
            margin: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _startNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Bắt đầu cuộc trò chuyện mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey[200]),

          // Conversations List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50))),
                        SizedBox(height: 16),
                        Text('Đang tải...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshConversations,
                    color: Color(0xFF4CAF50),
                    child: _conversations.isEmpty
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
                                  'Chưa có cuộc trò chuyện nào',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Bắt đầu cuộc trò chuyện đầu tiên',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _startNewChat,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text('Bắt đầu ngay'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              return _buildConversationTile(_conversations[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
            if (conversation.isOnline)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          conversation.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (conversation.lastMessage != null)
              Text(
                conversation.lastMessage!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 4),
            Text(conversation.timeString, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        trailing: conversation.unreadCount > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Color(0xFF4CAF50), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SendbirdChatScreen(conversationId: conversation.id)),
          );
        },
      ),
    );
  }
}

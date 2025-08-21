import 'package:cfv_mobile/screens/sendbird/index.dart';
import 'package:cfv_mobile/controller/sendbird_controller.dart';
import 'package:cfv_mobile/data/responses/sendbird_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendbirdConversationListScreen extends StatefulWidget {
  const SendbirdConversationListScreen({super.key});

  @override
  State<SendbirdConversationListScreen> createState() => _SendbirdConversationListScreenState();
}

class _SendbirdConversationListScreenState extends State<SendbirdConversationListScreen> {
  late final SendbirdController _sendbirdController;

  @override
  void initState() {
    super.initState();
    _sendbirdController = Get.put(SendbirdController());
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    try {
      await _sendbirdController.initialize();

      final connected = await _sendbirdController.connectUser();
      if (connected) {
        await _sendbirdController.loadConversations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể khởi tạo: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _refreshConversations() async {
    await _sendbirdController.loadConversations();
  }

  Future<void> _startNewChat() async {
    try {
      final title = await _showNewChatDialog();
      if (title != null && title.isNotEmpty) {
        final newConversation = await _sendbirdController.createNewConversation(title);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SendbirdChatScreen(conversation: newConversation)),
          );
        }
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
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Tin nhắn',
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: _startNewChat,
              icon: Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_sendbirdController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_sendbirdController.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chưa có cuộc trò chuyện nào', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Bắt đầu cuộc trò chuyện mới để kết nối', style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startNewChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Bắt đầu cuộc trò chuyện'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshConversations,
          child: ListView.builder(
            itemCount: _sendbirdController.conversations.length,
            itemBuilder: (context, index) {
              final conversation = _sendbirdController.conversations[index];
              return _buildConversationTile(conversation);
            },
          ),
        );
      }),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(
          conversation.title.isNotEmpty ? conversation.title[0].toUpperCase() : 'C',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        conversation.title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conversation.lastMessage != null)
            Text(
              conversation.lastMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 4),
          Row(
            children: [
              if (conversation.lastMessageTime != null)
                Text(conversation.timeString, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Spacer(),
              if (conversation.unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SendbirdChatScreen(conversation: conversation)),
        );
      },
    );
  }
}

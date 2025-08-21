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

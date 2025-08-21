import "package:cfv_mobile/screens/message/message_screen.dart";
import "package:flutter/material.dart";

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  final List<ConversationItem> conversations = const [
    ConversationItem(
      name: "Vườn Xanh Miền Tây",
      message: "Cảm ơn bạn đã quan tâm đến sả...",
      time: "10:37",
      unreadCount: 2,
      isOnline: true,
    ),
    ConversationItem(
      name: "Vườn Sạch Đồng Tháp",
      message: "Rau muống nước hiện tại còn 30kg.",
      time: "Hôm qua",
      unreadCount: 0,
      isOnline: false,
    ),
    ConversationItem(
      name: "Nông Trại Hạnh Phúc",
      message: "Chúng tôi sẽ có lô rau mới vào tu...",
      time: "2 ngày trước",
      unreadCount: 1,
      isOnline: true,
    ),
    ConversationItem(
      name: "Vườn Organic Cần Thơ",
      message: "Cảm ơn bạn đã đặt hàng!",
      time: "1 tuần trước",
      unreadCount: 0,
      isOnline: false,
    ),
  ];

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
              // App Bar
              Container(
                height: 56,
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
          Container(height: 1, color: Colors.grey[200]),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return ConversationListTile(
                  conversation: conversations[index],
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MessagesScreen()));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConversationListTile extends StatelessWidget {
  final ConversationItem conversation;
  final VoidCallback onTap;

  const ConversationListTile({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Color(0xFFB8E6B8), shape: BoxShape.circle),
                  child: Icon(Icons.person, color: Color(0xFF4CAF50), size: 28),
                ),
                if (conversation.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(conversation.time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.message,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const BottomNavItem({super.key, required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: isActive ? Color(0xFF4CAF50) : Colors.grey[600]),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Color(0xFF4CAF50) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class ConversationItem {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final bool isOnline;

  const ConversationItem({
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
  });
}

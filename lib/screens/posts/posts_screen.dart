import 'package:flutter/material.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLiked = false;
  int _likeCount = 24;

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount--;
      } else {
        _likeCount++;
      }
      _isLiked = !_isLiked;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tin nhắn đã được gửi: ${_messageController.text}'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Bài Đăng',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Post Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                          child: Icon(Icons.person, color: Colors.green.shade600, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vườn của Thanh Tâm',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              Row(
                                children: [
                                  Text('0982912617', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text('2 giờ trước', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.more_horiz, color: Colors.grey.shade500),
                      ],
                    ),
                  ),

                  // Post Content
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Xà lách xoong không chỉ là nguyên liệu quan thuộc trong các món ăn như canh, sinh tố mà còn có tác dụng chữa bệnh rất tốt. Rau chứa nhiều vitamin A, C, K, những chất này có tác dụng chống oxy hóa rất tốt, giúp cơ thể tăng cường sức đề kháng, làm đẹp da. Vì vậy việc ăn xà lách xoong thường xuyên sẽ giúp cơ thể khỏe mạnh hơn.',
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Main Image
                  Container(
                    width: double.infinity,
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 60, color: Colors.green.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Xà lách xoong tươi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Product Label
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sản phẩm đính kèm',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Product Thumbnail
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Icon(Icons.eco, color: Colors.green.shade400, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Xà lách xoong tươi',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '25,000 VNĐ/kg',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Gửi tin nhắn cho Gardener',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Nhập tin nhắn...',
                                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.green.shade400),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: Colors.green.shade600, shape: BoxShape.circle),
                                child: const Icon(Icons.send, color: Colors.white, size: 18),
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

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/controller/home_controller.dart';
import 'package:cfv_mobile/controller/sendbird_controller.dart';
import 'package:cfv_mobile/data/responses/home_response.dart';
import 'package:cfv_mobile/screens/posts/post_detail.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final Map<String, TextEditingController> _postMessageControllers = {};
  final Map<String, bool> _postLikedStates = {};
  final Map<String, int> _postLikeCounts = {};

  late HomeController _homeController;
  late AuthenticationController _authController;
  late SendbirdController _sendbirdController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _authController = Get.find<AuthenticationController>();
    _sendbirdController = Get.find<SendbirdController>();
    _loadPosts();
    _initializeSendbird();
  }

  Future<void> _initializeSendbird() async {
    try {
      final userId = _authController.currentUser?.accountId ?? '';
      final name = _authController.currentUser?.name ?? '';

      if (userId.isNotEmpty && name.isNotEmpty) {
        await _sendbirdController.initialize();
        await _sendbirdController.connectUser();

        // Check connection status
        if (_sendbirdController.isUserConnected.value) {
          debugPrint('✅ Sendbird connected successfully');
        } else {
          debugPrint('⚠️ Sendbird connection failed');
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize Sendbird: $e');
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      await _homeController.loadPostsData();

      for (final post in _homeController.posts) {
        if (post.postId != null) {
          _postLikedStates[post.postId!] = false;
          _postLikeCounts[post.postId!] = 24;
          _postMessageControllers[post.postId!] = TextEditingController();
        }
      }
    } catch (e) {
      debugPrint('Failed to load posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(String postId, String gardenerId, String gardenerName) async {
    final message = _postMessageControllers[postId]?.text.trim() ?? '';
    if (message.isEmpty) return;

    try {
      // Check connection status first
      if (!_sendbirdController.isUserConnected.value) {
        debugPrint('🔄 Reconnecting to Sendbird...');
        await _sendbirdController.connectUser();
      }

      final conversationTitle = 'Chat với ${gardenerName.isNotEmpty ? gardenerName : 'Gardener'}';

      try {
        // Create or get conversation first
        final conversation = await _sendbirdController.createNewConversation(
          conversationTitle,
          initialMessage: message,
          postId: postId,
          gardenerId: gardenerId,
        );

        // Open the conversation to set it as current
        await _sendbirdController.openConversation(conversation);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tin nhắn đã được gửi: $message'), backgroundColor: Colors.green.shade600),
        );

        _postMessageControllers[postId]?.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi gửi tin nhắn: $e'), backgroundColor: Colors.red.shade600));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e'), backgroundColor: Colors.red.shade600));
    }
  }

  Future<void> _reconnectSendbird() async {
    try {
      await _sendbirdController.forceReconnect();
      if (_sendbirdController.isUserConnected.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kết nối Sendbird đã được khôi phục'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể khôi phục kết nối: $e'), backgroundColor: Colors.red));
    }
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Chưa có ngày';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Widget _buildPostCard(PostModel post, int index) {
    final postId = post.postId ?? '';
    final isLiked = _postLikedStates[postId] ?? false;
    final likeCount = _postLikeCounts[postId] ?? 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          _buildPostContent(post),
          _buildPostImage(post),
          _buildAttachedProduct(post),
          _buildMessageSection(post, postId, isLiked, likeCount),
        ],
      ),
    );
  }

  Widget _buildPostHeader(PostModel post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
            child: post.gardenerAvatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      post.gardenerAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, color: Colors.green.shade600, size: 20),
                    ),
                  )
                : Icon(Icons.person, color: Colors.green.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.gardenerName ?? 'Vườn không tên',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Row(
                  children: [
                    Text('0982912617', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(_formatTimeAgo(post.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostModel post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title ?? 'Không có tiêu đề',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4),
          ),
          if (post.content != null && post.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              post.content!.length > 150 ? '${post.content!.substring(0, 150)}...' : post.content!,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
          ],
          if (post.harvestStatus != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    post.harvestStatusData.$2,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.harvestStatusData.$1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostImage(PostModel post) {
    if (post.thumbNail == null || post.thumbNail!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          post.thumbNail!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 60, color: Colors.green.shade400),
              const SizedBox(height: 8),
              Text(
                'Hình ảnh sản phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachedProduct(PostModel post) {
    if (post.productId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm đính kèm',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
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
                    Text(
                      post.title ?? 'Sản phẩm',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    if (post.price != null)
                      Text(
                        '${NumberFormat('#,###').format(post.price)} ${post.currency ?? 'VNĐ'}/${post.weightUnit ?? 'kg'}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade600),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(PostModel post, String postId, bool isLiked, int likeCount) {
    return Container(
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
                  controller: _postMessageControllers[postId],
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
                onTap: () => _sendMessage(postId, post.gardenerId ?? '', post.gardenerName ?? ''),
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
    );
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
        actions: [
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _sendbirdController.isUserConnected.value ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _sendbirdController.isUserConnected.value ? '🟢' : '🔴',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          Obx(
            () => _sendbirdController.isUserConnected.value
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(Icons.refresh, color: Colors.red.shade600),
                    onPressed: _reconnectSendbird,
                    tooltip: 'Kết nối lại Sendbird',
                  ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green.shade600),
            onPressed: _loadPosts,
            tooltip: 'Làm mới bài đăng',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ..._homeController.posts.map((post) => _buildPostCard(post, 0)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    for (final controller in _postMessageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

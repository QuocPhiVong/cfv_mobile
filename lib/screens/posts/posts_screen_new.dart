import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';
import 'package:cfv_mobile/controller/app_controller.dart';
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/controller/home_controller.dart';
import 'package:cfv_mobile/controller/sendbird_controller.dart';
import 'package:cfv_mobile/data/responses/home_response.dart';
import 'package:cfv_mobile/screens/product/product_details.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final Map<String, TextEditingController> _postMessageControllers = {};
  final Map<String, bool> _postLikedStates = {};
  final Map<String, int> _postLikeCounts = {};

  // Video player controllers for posts with videos
  final Map<int, VideoPlayerController> _videoControllers = {};

  // Track which posts are expanded
  Set<int> expandedPosts = {};
  Set<int> likedPosts = {};

  late HomeController _homeController;
  late AuthenticationController _authController;
  late SendbirdController _sendbirdController;
  late TabController _tabController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _authController = Get.find<AuthenticationController>();
    _sendbirdController = Get.find<SendbirdController>();
    _tabController = TabController(length: 2, vsync: this);
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
      await _homeController.loadCategoriesData();
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

  Future<void> _sendMessage(int postIndex, String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Get the post data
      final post = _homeController.posts[postIndex];
      final postId = post.postId ?? '';
      final gardenerId = post.gardenerId ?? '';
      final gardenerName = post.gardenerName ?? '';

      if (postId.isEmpty || gardenerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xác định thông tin bài đăng'), backgroundColor: Colors.red),
        );
        return;
      }

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

        // Clear the message input
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

  String timeAgoSinceDate(DateTime date, {bool numericDates = true}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 8) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Chưa có ngày';
    return timeAgoSinceDate(date);
  }

  List<PostModel> get _allPosts => _homeController.posts;

  List<PostModel> get _favoritePosts {
    // Filter posts that are liked
    return _homeController.posts.where((post) {
      final postId = post.postId ?? '';
      return likedPosts.contains(_homeController.posts.indexOf(post));
    }).toList();
  }

  Container postItem(PostModel post, bool isExpanded, int index, BuildContext context, bool isLiked) {
    // Video player logic
    Widget? videoWidget;
    if (post.thumbNail != null && post.thumbNail!.endsWith('.mp4')) {
      if (!_videoControllers.containsKey(index)) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(post.thumbNail!));
        controller.setLooping(true);
        controller.initialize().then((_) {
          if (mounted) {
            controller.play();
            setState(() {});
          }
        });
        _videoControllers[index] = controller;
      } else {
        final vidController = _videoControllers[index]!;
        if (vidController.value.isInitialized && !vidController.value.isPlaying) {
          vidController.play();
        }
      }
      final vidController = _videoControllers[index];
      videoWidget = vidController != null && vidController.value.isInitialized
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(aspectRatio: vidController.value.aspectRatio, child: VideoPlayer(vidController)),
            )
          : Container(
              height: 200,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black12),
              child: const Center(child: CircularProgressIndicator()),
            );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      post.gardenerAvatar ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, color: Colors.green.shade600, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.gardenerName ?? "",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Text(
                        post.createdAt != null ? timeAgoSinceDate(post.createdAt!) : 'Chưa có ngày',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.title ?? 'Bài đăng không có tiêu đề',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 8),

          // Post description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(
                  data: isExpanded
                      ? post.content ?? ""
                      : post.content?.substring(0, post.content!.length > 30 ? 30 : post.content!.length) ?? "",
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedPosts.remove(index);
                      } else {
                        expandedPosts.add(index);
                      }
                    });
                  },
                  child: Text(
                    isExpanded ? 'Thu gọn' : 'Xem thêm',
                    style: TextStyle(fontSize: 14, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (post.harvestStatus != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Icon(post.harvestStatusData.$2, color: Colors.white, size: 20),
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

          const SizedBox(height: 16),

          if (post.thumbNail != null && post.thumbNail!.endsWith('.mp4'))
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: videoWidget ?? const SizedBox.shrink())
          else if (post.thumbNail != null && post.thumbNail!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(post.thumbNail ?? ""), fit: BoxFit.cover),
              ),
            ),
          SizedBox(height: 16),

          // Product attachment - UPDATED with navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sản phẩm đính kèm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Navigate to ProductDetailScreen with product data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          AppController.productDepositPercentage[post.productId ?? ''] = post.depositPercentage ?? 0;
                          return ProductDetailScreen(productId: post.productId ?? '', postId: post.postId ?? '');
                        },
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Icon(Icons.eco, color: Colors.green.shade600, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title ?? "",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            Text(
                              '${post.price} ${post.currency}/${post.weightUnit ?? "VNĐ/kg"}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade600),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    children: [
                      const TextSpan(text: 'Đặt cọc trước: '),
                      TextSpan(
                        text: '${post.depositPercentage}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Like button - UPDATED
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _homeController.favPost(_authController.currentUser?.accountId ?? '', post.postId ?? '').then((
                      value,
                    ) {
                      if (value == true) {
                        setState(() {});
                      }
                    });
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('Yêu thích', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to product details or perform detail action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          AppController.productDepositPercentage[post.productId ?? ''] = post.depositPercentage ?? 0;
                          return ProductDetailScreen(productId: post.productId ?? '', postId: post.postId ?? '');
                        },
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text('Chi tiết', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FIXED: Functional Message box at the bottom of each post
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8), // Light green background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.eco, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Gửi tin nhắn cho Gardener',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: TextField(
                          controller: _postMessageControllers[post.postId ?? ''],
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (value) {
                            _sendMessage(index, value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _sendMessage(index, _postMessageControllers[post.postId ?? '']?.text ?? '');
                      },
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
    );
  }

  Widget _buildCategoryItem({required String imagePath, required String label}) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.green.shade100,
                    child: Icon(Icons.eco, color: Colors.green.shade600, size: 30),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<PostModel> posts) {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Categories section
            SizedBox(
              height: 120,
              child: Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _homeController.isCategoriesLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _homeController.categories.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildCategoryItem(
                              imagePath: '/placeholder.svg?height=60&width=60',
                              label: _homeController.categories[index].name,
                            );
                          },
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ...posts.asMap().entries.map((entry) {
              final index = entry.key;
              final post = entry.value;
              bool isExpanded = expandedPosts.contains(index);
              bool isLiked = likedPosts.contains(index);

              // Initialize controller for this post if not exists
              if (!_postMessageControllers.containsKey(post.postId)) {
                _postMessageControllers[post.postId ?? ''] = TextEditingController();
              }

              return postItem(post, isExpanded, index, context, isLiked);
            }),
            const SizedBox(height: 100),
          ],
        ),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.green.shade600,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Yêu thích'),
          ],
        ),
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
          : TabBarView(
              controller: _tabController,
              children: [_buildPostsList(_allPosts), _buildPostsList(_favoritePosts)],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    for (final controller in _postMessageControllers.values) {
      controller.dispose();
    }
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

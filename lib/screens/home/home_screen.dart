import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/controller/home_controller.dart';
import 'package:cfv_mobile/data/responses/home_response.dart';
import 'package:cfv_mobile/screens/product/product_details.dart';
import 'package:cfv_mobile/screens/cart/cart_info.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // VideoPlayerControllers for posts with videos
  final Map<int, VideoPlayerController> _videoControllers = {};
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

  // Track which posts are expanded
  Set<int> expandedPosts = {};
  Set<int> likedPosts = {};

  HomeController get homeController => Get.find<HomeController>();
  AuthenticationController get authController =>
      Get.find<AuthenticationController>();
  // Controllers for message input fields
  Map<int, TextEditingController> messageControllers = {};

  @override
  void initState() {
    super.initState();
    homeController.loadCategoriesData();
    homeController.loadGardenersData();
    homeController.loadPostsData();
  }

  @override
  void dispose() {
    // Dispose all message controllers
    for (var controller in messageControllers.values) {
      controller.dispose();
    }
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section (keeping existing code)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Text(
                              'Vòng Quốc Phi',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CartInfoScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade100,
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.blue.shade600,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.shade100,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Colors.green.shade600,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories section (keeping existing code)
              SizedBox(
                height: 120,
                child: Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: homeController.isCategoriesLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: homeController.categories.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildCategoryItem(
                                imagePath:
                                    '/placeholder.svg?height=60&width=60',
                                label: homeController.categories[index].name,
                              );
                            },
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Filter buttons (keeping existing code)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gần Tôi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lọc Theo Vị Trí',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Gardens list section (keeping existing code)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh Sách Vườn',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Xem Thêm',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => homeController.isGardenersLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : homeController.gardeners.isEmpty
                          ? const Center(child: Text('Không có vườn nào'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: homeController.gardeners.length,
                              itemBuilder: (context, index) {
                                final garden = homeController.gardeners[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
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
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              garden.avatar != null &&
                                                  garden.avatar!.isNotEmpty
                                              ? NetworkImage(garden.avatar!)
                                              : null,
                                          child:
                                              garden.avatar == null ||
                                                  garden.avatar!.isEmpty
                                              ? Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.grey,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    garden.name ??
                                                        'Vườn Không Tên',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow: TextOverflow
                                                        .ellipsis, // Truncate long text
                                                  ),
                                                ),
                                                if (garden.isVerified ==
                                                    true) ...[
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors
                                                        .green, // Changed to green
                                                    size: 16,
                                                  ),
                                                ],
                                              ],
                                            ),

                                            const SizedBox(height: 4),
                                            Text(
                                              "${garden.addresses?[0].city}, ${garden.addresses?[0].country}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  "Đã tham gia vào: ${DateFormat("MMMM, y", "vi").format(garden.createAt?.toLocal() ?? DateTime.now())}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
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
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Posts section - UPDATED
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bài Đăng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Xem thêm',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Obx(
                      () => homeController.isPostsLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : homeController.posts.isEmpty
                          ? const Center(child: Text('Không có bài đăng nào'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: homeController.posts.length,
                              itemBuilder: (context, index) {
                                final post = homeController.posts[index];
                                bool isExpanded = expandedPosts.contains(index);
                                bool isLiked = likedPosts.contains(index);

                                // Initialize controller for this post if not exists
                                if (!messageControllers.containsKey(index)) {
                                  messageControllers[index] =
                                      TextEditingController();
                                }

                                return postItem(
                                  post,
                                  isExpanded,
                                  index,
                                  context,
                                  isLiked,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Container postItem(
    PostModel post,
    bool isExpanded,
    int index,
    BuildContext context,
    bool isLiked,
  ) {
    // Video player logic
    Widget? videoWidget;
    if (post.thumbNail != null && post.thumbNail!.endsWith('.mp4')) {
      if (!_videoControllers.containsKey(index)) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(post.thumbNail!),
        );
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
        if (vidController.value.isInitialized &&
            !vidController.value.isPlaying) {
          vidController.play();
        }
      }
      final vidController = _videoControllers[index];
      videoWidget = vidController != null && vidController.value.isInitialized
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: vidController.value.aspectRatio,
                child: VideoPlayer(vidController),
              ),
            )
          : Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black12,
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade100,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.gardenerName ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '0982912617 • '
                        '${post.createdAt != null ? timeAgoSinceDate(post.createdAt!) : 'Chưa có ngày'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Post description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpanded
                      ? post.content ?? ""
                      : post.content?.substring(
                              0,
                              post.content!.length > 30
                                  ? 30
                                  : post.content!.length,
                            ) ??
                            "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                  Icons.agriculture,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tình trạng mùa vụ',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: videoWidget ?? const SizedBox.shrink(),
            )
          else if (post.thumbNail != null && post.thumbNail!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(post.thumbNail ?? ""),
                  fit: BoxFit.cover,
                ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Navigate to ProductDetailScreen with product data
                    final productData = {
                      'name': post.title ?? "",
                      'price': "${post.price}",
                      'quantity': post.weightUnit ?? "",
                      // 'garden': post. ?? "",
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: post.productId ?? '',
                        ),
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
                        child: Icon(
                          Icons.eco,
                          color: Colors.green.shade600,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${post.price} ${post.currency}/${post.weightUnit ?? "VNĐ/kg"}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
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
                        text: '30%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
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
                    homeController
                        .favPost(
                          authController.currentUser?.accountId ?? '',
                          post.postId ?? '',
                        )
                        .then((value) {
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
                      Text(
                        'Yêu thích',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to product details or perform detail action
                    final productData = {
                      'name': post.title ?? "",
                      'price': "${post.price}",
                      'quantity': post.weightUnit ?? "",
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: post.productId ?? '',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Chi tiết',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: messageControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
                        _sendMessage(index, messageControllers[index]!.text);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
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

  // Method to handle sending messages
  void _sendMessage(int postIndex, String message) {
    if (message.trim().isNotEmpty) {
      // Here you would typically send the message to your backend
      print('Sending message for post $postIndex: $message');

      // Clear the input field
      messageControllers[postIndex]?.clear();

      // Show a confirmation (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tin nhắn đã được gửi!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Updated product card widget with navigation
  // Widget _buildProductCard(Map<String, String> product, double width) {
  //   ...unused code...
  // }

  Widget _buildCategoryItem({
    required String imagePath,
    required String label,
  }) {
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
                    child: Icon(
                      Icons.eco,
                      color: Colors.green.shade600,
                      size: 30,
                    ),
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

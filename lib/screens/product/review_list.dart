import 'package:flutter/material.dart';

class ReviewListScreen extends StatefulWidget {
  final String? productName;
  final String? productId;

  const ReviewListScreen({super.key, this.productName, this.productId});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  String selectedFilter = 'Tất cả';
  String selectedSort = 'Mới nhất';

  final List<String> filterOptions = ['Tất cả', '5 sao', '4 sao', '3 sao', '2 sao', '1 sao'];
  final List<String> sortOptions = ['Mới nhất', 'Cũ nhất', 'Đánh giá cao', 'Đánh giá thấp'];

  // Sample review data - in real app, this would come from API
  final List<Map<String, dynamic>> reviews = [
    {
      'id': '1',
      'userName': 'Nguyễn Thị A',
      'rating': 5.0,
      'timeAgo': '2 ngày trước',
      'comment': 'Xà lách rất tươi và sạch, ăn ngon lắm! Giao hàng nhanh, đóng gói cẩn thận. Sẽ mua lại lần sau.',
      'purchase': 'Đã mua: Xà lách xoong tươi (2kg)',
      'helpful': 12,
      'images': ['image1.jpg', 'image2.jpg'],
    },
    {
      'id': '2',
      'userName': 'Trần Văn B',
      'rating': 4.5,
      'timeAgo': '1 tuần trước',
      'comment': 'Giao hàng nhanh, rau còn tươi rói. Sẽ ủng hộ tiếp. Chất lượng tốt, giá cả hợp lý.',
      'purchase': 'Đã mua: Xà lách xoong tươi (1kg)',
      'helpful': 8,
      'images': [],
    },
    {
      'id': '3',
      'userName': 'Lê Thị C',
      'rating': 5.0,
      'timeAgo': '2 tuần trước',
      'comment':
          'Rau rất tươi ngon, không có lá héo. Vườn này trồng rau sạch thật sự. Tôi đã mua nhiều lần và luôn hài lòng.',
      'purchase': 'Đã mua: Xà lách xoong tươi (3kg)',
      'helpful': 15,
      'images': ['image3.jpg'],
    },
    {
      'id': '4',
      'userName': 'Phạm Minh D',
      'rating': 4.0,
      'timeAgo': '3 tuần trước',
      'comment': 'Chất lượng tốt, nhưng có một vài lá hơi già. Nhìn chung vẫn hài lòng với sản phẩm.',
      'purchase': 'Đã mua: Xà lách xoong tươi (1.5kg)',
      'helpful': 5,
      'images': [],
    },
    {
      'id': '5',
      'userName': 'Hoàng Thị E',
      'rating': 5.0,
      'timeAgo': '1 tháng trước',
      'comment': 'Xuất sắc! Rau rất tươi, ngọt và giòn. Đóng gói cẩn thận, giao hàng đúng hẹn. Highly recommended!',
      'purchase': 'Đã mua: Xà lách xoong tươi (2.5kg)',
      'helpful': 20,
      'images': ['image4.jpg', 'image5.jpg', 'image6.jpg'],
    },
    {
      'id': '6',
      'userName': 'Vũ Văn F',
      'rating': 3.5,
      'timeAgo': '1 tháng trước',
      'comment': 'Rau tươi nhưng có mùi hơi lạ. Có thể do vận chuyển xa. Chất lượng tạm được.',
      'purchase': 'Đã mua: Xà lách xoong tươi (1kg)',
      'helpful': 3,
      'images': [],
    },
  ];

  List<Map<String, dynamic>> get filteredReviews {
    List<Map<String, dynamic>> filtered = List.from(reviews);

    // Apply rating filter
    if (selectedFilter != 'Tất cả') {
      int targetRating = int.parse(selectedFilter.split(' ')[0]);
      filtered = filtered.where((review) {
        return review['rating'].floor() == targetRating;
      }).toList();
    }

    // Apply sorting
    switch (selectedSort) {
      case 'Mới nhất':
        // Already in newest first order
        break;
      case 'Cũ nhất':
        filtered = filtered.reversed.toList();
        break;
      case 'Đánh giá cao':
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'Đánh giá thấp':
        filtered.sort((a, b) => a['rating'].compareTo(b['rating']));
        break;
    }

    return filtered;
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    double sum = reviews.fold(0.0, (sum, review) => sum + review['rating']);
    return sum / reviews.length;
  }

  Map<int, int> get ratingDistribution {
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      int rating = review['rating'].floor();
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh giá sản phẩm',
          style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Overall rating summary
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Average rating
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < averageRating.floor()
                                    ? Icons.star
                                    : index < averageRating
                                    ? Icons.star_half
                                    : Icons.star_border,
                                color: Colors.orange,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reviews.length} đánh giá',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    // Rating distribution
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          for (int i = 5; i >= 1; i--)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('$i'),
                                  const SizedBox(width: 4),
                                  Icon(Icons.star, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: reviews.isEmpty ? 0 : (ratingDistribution[i] ?? 0) / reviews.length,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      '${ratingDistribution[i] ?? 0}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter and sort options
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Filter dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        isExpanded: true,
                        items: filterOptions.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSort,
                        isExpanded: true,
                        items: sortOptions.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSort = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Reviews list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredReviews.length,
              itemBuilder: (context, index) {
                final review = filteredReviews[index];
                return _buildReviewCard(review);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          // User info and rating
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                child: Icon(Icons.person, color: Colors.green.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review['rating'].floor()
                                  ? Icons.star
                                  : index < review['rating']
                                  ? Icons.star_half
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review['rating'].toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Time
              Text(review['timeAgo'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),

          const SizedBox(height: 16),

          // Review comment
          Text(review['comment'], style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),

          const SizedBox(height: 12),

          // Purchase info
          Text(
            review['purchase'],
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),

          // Review images (if any)
          if (review['images'].isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review['images'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.image, color: Colors.grey.shade500, size: 30),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Helpful section
          Row(
            children: [
              Text('Hữu ích?', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // Handle helpful action
                },
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${review['helpful']}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  // Handle report action
                },
                child: Text('Báo cáo', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

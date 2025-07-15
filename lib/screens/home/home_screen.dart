import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which posts are expanded
  Set<int> expandedPosts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
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
                    const SizedBox(height: 20),
                    
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Categories section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryItem(
                      icon: Icons.eco,
                      label: 'Rau Lá',
                      color: Colors.green,
                    ),
                    _buildCategoryItem(
                      icon: Icons.agriculture,
                      label: 'Củ Quả',
                      color: Colors.orange,
                    ),
                    _buildCategoryItem(
                      icon: Icons.apple,
                      label: 'Trái Cây',
                      color: Colors.red,
                    ),
                    _buildCategoryItem(
                      icon: Icons.grass,
                      label: 'Nấm Các Loại',
                      color: Colors.brown,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Filter buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gần Tồi',
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
                          borderRadius: BorderRadius.circular(8),
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
              
              // Products section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sản Phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Xem Thêm',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final products = [
                          {
                            'name': 'Xà lách xoong tươi',
                            'price': '25,000',
                            'quantity': '50',
                            'garden': 'Vườn Xanh Miền Tây',
                          },
                          {
                            'name': 'Rau muống hữu cơ',
                            'price': '20,000',
                            'quantity': '30',
                            'garden': 'Vườn Sạch Đồng Tháp',
                          },
                          {
                            'name': 'Cải thìa baby',
                            'price': '35,000',
                            'quantity': '25',
                            'garden': 'Nông Trại Hạnh Phúc',
                          },
                          {
                            'name': 'Rau dền đỏ',
                            'price': '18,000',
                            'quantity': '40',
                            'garden': 'Vườn Organic Cần Thơ',
                          },
                          {
                            'name': 'Cải ngọt Đà Lạt',
                            'price': '30,000',
                            'quantity': '35',
                            'garden': 'Vườn Cao Nguyên',
                          },
                          {
                            'name': 'Rau má tươi',
                            'price': '15,000',
                            'quantity': '60',
                            'garden': 'Vườn Thuần Việt',
                          },
                        ];
                        
                        final product = products[index];
                        
                        return Container(
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
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.eco,
                                    color: Colors.green.shade600,
                                    size: 40,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product['name']!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${product['price']} VNĐ/kg',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        'Số lượng: ${product['quantity']} kg',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          product['garden']!,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Gardens list section
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Xem Thêm',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final gardens = [
                          {
                            'name': 'Vườn Xanh Miền Tây',
                            'address': '123 Đường Cần Thơ, An Giang',
                            'rating': '4.8',
                            'joinDate': 'Tham gia: Tháng 3/2023',
                          },
                          {
                            'name': 'Vườn Sạch Đồng Tháp',
                            'address': '456 Đường Cao Lãnh, Đồng Tháp',
                            'rating': '4.9',
                            'joinDate': 'Tham gia: Tháng 1/2023',
                          },
                          {
                            'name': 'Nông Trại Hạnh Phúc',
                            'address': '789 Đường Mỹ Tho, Tiền Giang',
                            'rating': '4.7',
                            'joinDate': 'Tham gia: Tháng 5/2023',
                          },
                          {
                            'name': 'Vườn Organic Cần Thơ',
                            'address': '321 Đường Ninh Kiều, Cần Thơ',
                            'rating': '4.6',
                            'joinDate': 'Tham gia: Tháng 2/2023',
                          },
                        ];
                        
                        final garden = gardens[index];
                        
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.agriculture,
                                  color: Colors.green.shade600,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      garden['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      garden['address']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          garden['rating']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          garden['joinDate']!,
                                          style: TextStyle(
                                            fontSize: 11,
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
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Posts section
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Xem thêm',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final posts = [
                          {
                            'gardenName': 'Vườn Xanh Miền Tây',
                            'phone': '0901 234 567',
                            'timeAgo': '2 giờ trước',
                            'title': 'Mùa thu hoạch cà chua bí đá bắt đầu!',
                            'shortDescription': 'Vườn chúng tôi vừa thu hoạch lô cà chua bí organic đầu tiên của năm...',
                            'fullDescription': 'Vườn chúng tôi vừa thu hoạch lô cà chua bí organic đầu tiên của năm. Những quả cà chua được trồng hoàn toàn tự nhiên, không sử dụng thuốc trừ sâu hay phân bón hóa học. Chất lượng tuyệt vời với độ ngọt tự nhiên và màu sắc đẹp mắt.',
                            'seasonInfo': 'Gieo trồng: 15/08/2024 - Thu hoạch: 20/12/2024',
                          },
                          {
                            'gardenName': 'Vườn Sạch Đồng Tháp',
                            'phone': '0902 345 678',
                            'timeAgo': '5 giờ trước',
                            'title': 'Rau muống nước mùa khô chất lượng cao',
                            'shortDescription': 'Rau muống nước trồng theo phương pháp hữu cơ, tươi ngon và an toàn...',
                            'fullDescription': 'Rau muống nước trồng theo phương pháp hữu cơ, tươi ngon và an toàn cho sức khỏe. Được trồng trong môi trường nước sạch, không ô nhiễm. Lá xanh mướt, thân giòn ngọt, rất thích hợp cho các món ăn gia đình.',
                            'seasonInfo': 'Gieo trồng: 01/10/2024 - Thu hoạch: 15/01/2025',
                          },
                          {
                            'gardenName': 'Nông Trại Hạnh Phúc',
                            'phone': '0903 456 789',
                            'timeAgo': '1 ngày trước',
                            'title': 'Xà lách xoong tươi mới thu hoạch',
                            'shortDescription': 'Xà lách xoong được trồng trong nhà kính, kiểm soát chất lượng nghiêm ngặt...',
                            'fullDescription': 'Xà lách xoong được trồng trong nhà kính, kiểm soát chất lượng nghiêm ngặt từ khâu gieo trồng đến thu hoạch. Lá xà lách giòn ngọt, giàu vitamin và khoáng chất, hoàn hảo cho salad và các món ăn healthy.',
                            'seasonInfo': 'Gieo trồng: 10/09/2024 - Thu hoạch: 25/01/2025',
                          },
                        ];
                        
                        final post = posts[index];
                        bool isExpanded = expandedPosts.contains(index);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Post header
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.shade100,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.green.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['gardenName']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '${post['phone']} • ${post['timeAgo']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Post title
                              Text(
                                post['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Post description
                              Text(
                                isExpanded ? post['fullDescription']! : post['shortDescription']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Seasonal information
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.green.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Thông tin mùa vụ:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            post['seasonInfo']!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.green.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Post image
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.eco,
                                  color: Colors.green.shade600,
                                  size: 60,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Expand/Collapse button
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
                        );
                      },
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

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
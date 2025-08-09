import 'package:cfv_mobile/screens/appointment/create_appointment.dart';
import 'package:cfv_mobile/screens/product/product_details.dart';
import 'package:flutter/material.dart';

class GardenerProfileScreen extends StatefulWidget {
  final Map<String, String> gardenerData;

  const GardenerProfileScreen({super.key, required this.gardenerData});

  @override
  State<GardenerProfileScreen> createState() => _GardenerProfileScreenState();
}

class _GardenerProfileScreenState extends State<GardenerProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSort = 'Mới nhất';
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final List<String> _sortOptions = ['Mới nhất', 'Cũ nhất', 'Sắp xếp theo giá tăng dần', 'Sắp xếp theo giá giảm dần'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeProducts();
    _applySort();
  }

  void _initializeProducts() {
    _products = [
      {
        'name': 'Dưa chuột baby',
        'price': '22,000',
        'priceValue': 22000,
        'quantity': '40',
        'rating': '4.6',
        'dateAdded': DateTime(2024, 1, 15),
      },
      {
        'name': 'Cà chua bí đá hữu cơ',
        'price': '30,000',
        'priceValue': 30000,
        'quantity': '35',
        'rating': '4.9',
        'dateAdded': DateTime(2024, 1, 10),
      },
      {
        'name': 'Xà lách xoong tươi',
        'price': '25,000',
        'priceValue': 25000,
        'quantity': '50',
        'rating': '4.8',
        'dateAdded': DateTime(2024, 1, 20),
      },
      {
        'name': 'Rau cải ngọt',
        'price': '18,000',
        'priceValue': 18000,
        'quantity': '60',
        'rating': '4.7',
        'dateAdded': DateTime(2024, 1, 5),
      },
    ];
  }

  void _applySort() {
    List<Map<String, dynamic>> sortedProducts = List.from(_products);

    switch (_selectedSort) {
      case 'Sắp xếp theo giá tăng dần':
        sortedProducts.sort((a, b) => a['priceValue'].compareTo(b['priceValue']));
        break;
      case 'Sắp xếp theo giá giảm dần':
        sortedProducts.sort((a, b) => b['priceValue'].compareTo(a['priceValue']));
        break;
      case 'Mới nhất':
        sortedProducts.sort((a, b) => b['dateAdded'].compareTo(a['dateAdded']));
        break;
      case 'Cũ nhất':
        sortedProducts.sort((a, b) => a['dateAdded'].compareTo(b['dateAdded']));
        break;
    }

    setState(() {
      _filteredProducts = sortedProducts;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text(
          'Thông tin vườn',
          style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Garden profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                      child: Icon(Icons.person, color: Colors.green.shade600, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gardenerData['garden'] ?? 'Vườn Xanh Miền Tây',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.message, size: 18),
                                  label: const Text('Nhắn tin'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to Create Appointment Screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateAppointmentScreen(gardenerData: widget.gardenerData),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.calendar_today, size: 18),
                                  label: const Text('Tạo lịch hẹn'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                const SizedBox(height: 20),
                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    labelColor: Colors.green.shade600,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.green.shade600,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    tabs: const [
                      Tab(text: 'Giới thiệu'),
                      Tab(text: 'Sản phẩm'),
                      Tab(text: 'Bài viết'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildIntroductionTab(), _buildProductsTab(), _buildPostsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact information
          Container(
            padding: const EdgeInsets.all(20),
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
                const Text(
                  'Thông tin liên lạc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Tên vườn', widget.gardenerData['garden'] ?? 'Vườn Xanh Miền Tây'),
                _buildInfoRow('Đã tham gia', 'Tham gia: Tháng 3/2023'),
                _buildInfoRow('Số điện thoại', widget.gardenerData['phone'] ?? '0901 234 567'),
                _buildInfoRow('Địa chỉ cụ thể', '123 Đường Cần Thơ, An Giang'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Detailed description
          Container(
            padding: const EdgeInsets.all(20),
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
                const Text(
                  'Giới thiệu chi tiết',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chúng tôi là một trang trại hữu cơ chuyên trồng các loại rau xanh sạch, an toàn cho sức khỏe. Với hơn 10 năm kinh nghiệm trong lĩnh vực nông nghiệp, chúng tôi cam kết mang đến những sản phẩm chất lượng cao nhất cho khách hàng.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.agriculture, color: Colors.green.shade600, size: 60),
                      const SizedBox(height: 12),
                      Text(
                        'Hình ảnh vườn trồng',
                        style: TextStyle(color: Colors.green.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Certificate section
          Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green.shade600, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Chứng nhận',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCertificateItem(
                  'Chứng nhận Hữu cơ Việt Nam',
                  'Bộ Nông nghiệp và Phát triển Nông thôn',
                  '15/03/2024',
                  '15/03/2025',
                  Icons.eco,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        // Sort dropdown
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Text(
                'Sắp xếp theo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      isExpanded: true,
                      items: _sortOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSort = newValue;
                          });
                          _applySort();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Products grid - Fixed overflow issue
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, // Increased aspect ratio to prevent overflow
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              // TODO: update for product details
              productId: "123",
              // product: {
              //   'name': product['name'],
              //   'price': product['price'],
              //   'quantity': product['quantity'],
              //   'garden': widget.gardenerData['garden'] ?? 'Vườn Xanh Miền Tây',
              //   'phone': widget.gardenerData['phone'] ?? '0901 234 567',
              // },
            ),
          ),
        );
      },
      child: Container(
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
            // Image section - Fixed height
            Container(
              width: double.infinity,
              height: 100, // Fixed height to prevent overflow
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: Icon(Icons.eco, color: Colors.green.shade600, size: 40),
            ),
            // Content section - Fixed padding and layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
                    Text(
                      product['name'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Text(
                      '${product['price']} VNĐ/kg',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade600),
                    ),
                    const SizedBox(height: 4),
                    // Quantity and rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số lượng: ${product['quantity']} kg',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.orange),
                            const SizedBox(width: 2),
                            Text(
                              product['rating'],
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
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
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                        child: Icon(Icons.person, color: Colors.green.shade600, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.gardenerData['garden'] ?? 'Vườn Xanh Miền Tây',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const Text('2 giờ trước', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Post title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Mùa thu hoạch cà chua bí đá bắt đầu!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
                        'Vườn chúng tôi vừa thu hoạch lô cà chua bí organic đầu tiên của năm...... ',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Xem thêm',
                        style: TextStyle(fontSize: 14, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Season info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin mùa vụ:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                            ),
                            Text(
                              'Gieo trồng: 15/08/2024 - Thu hoạch: 20/12/2024',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Post image
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.eco, color: Colors.green.shade600, size: 60),
                ),
                const SizedBox(height: 16),
                // Product attachment
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
                      Row(
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cà chua bí đá hữu cơ',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                Text(
                                  '30,000 VNĐ/kg',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Like button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite_border, color: Colors.grey.shade500, size: 20),
                          const SizedBox(width: 4),
                          Text('Yêu thích', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ),
          const Text(': ', style: TextStyle(fontSize: 14, color: Colors.black87)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateItem(
    String name,
    String authority,
    String certDate,
    String expiryDate,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text('Cơ quan chứng nhận: $authority', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              Icon(Icons.verified, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ngày chứng nhận: $certDate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text('Ngày hết hạn: $expiryDate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(Icons.image, color: Colors.grey.shade500, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

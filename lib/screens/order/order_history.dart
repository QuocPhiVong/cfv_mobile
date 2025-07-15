import 'package:flutter/material.dart';
import 'order_detail.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sample orders data
  final List<Map<String, dynamic>> orders = [
    {
      'orderId': 'DH001234',
      'status': 'Chờ xác nhận',
      'statusColor': Colors.orange,
      'createdDate': '15/12/2024',
      'updatedDate': '15/12/2024',
      'productName': 'Xà lách xoong tươi',
      'quantity': 2,
      'price': 50000,
      'customerName': 'Vòng Quốc Phi',
      'customerPhone': '0982912617',
      'customerAddress': '123 Đường ABC, Quận 1, TP.HCM',
      'deliveries': [
        {
          'deliveryNumber': 1,
          'status': 'Chờ xác nhận',
          'statusColor': Colors.orange,
          'deliveryDate': '16/12/2024',
          'items': [
            {
              'productName': 'Xà lách xoong tươi',
              'deliveredQuantity': 0,
              'remainingQuantity': 2,
              'price': 50000,
            },
          ],
        },
      ],
    },
    {
      'orderId': 'DH001235',
      'status': 'Đã xác nhận',
      'statusColor': Colors.blue,
      'createdDate': '14/12/2024',
      'updatedDate': '15/12/2024',
      'productName': 'Rau muống hữu cơ',
      'quantity': 3,
      'price': 60000,
      'customerName': 'Vòng Quốc Phi',
      'customerPhone': '0982912617',
      'customerAddress': '123 Đường ABC, Quận 1, TP.HCM',
      'deliveries': [
        {
          'deliveryNumber': 1,
          'status': 'Đã xác nhận',
          'statusColor': Colors.blue,
          'deliveryDate': '16/12/2024',
          'items': [
            {
              'productName': 'Rau muống hữu cơ',
              'deliveredQuantity': 0,
              'remainingQuantity': 3,
              'price': 60000,
            },
          ],
        },
      ],
    },
    {
      'orderId': 'DH001236',
      'status': 'Đang giao',
      'statusColor': Colors.purple,
      'createdDate': '13/12/2024',
      'updatedDate': '16/12/2024',
      'productName': 'Cải thìa baby',
      'quantity': 1,
      'price': 35000,
      'customerName': 'Vòng Quốc Phi',
      'customerPhone': '0982912617',
      'customerAddress': '123 Đường ABC, Quận 1, TP.HCM',
      'deliveries': [
        {
          'deliveryNumber': 1,
          'status': 'Đang giao',
          'statusColor': Colors.purple,
          'deliveryDate': '16/12/2024',
          'items': [
            {
              'productName': 'Cải thìa baby',
              'deliveredQuantity': 0,
              'remainingQuantity': 1,
              'price': 35000,
            },
          ],
        },
      ],
    },
    {
      'orderId': 'DH001237',
      'status': 'Đã giao hàng',
      'statusColor': Colors.teal,
      'createdDate': '12/12/2024',
      'updatedDate': '15/12/2024',
      'productName': 'Rau cải ngọt',
      'quantity': 2,
      'price': 40000,
      'customerName': 'Vòng Quốc Phi',
      'customerPhone': '0982912617',
      'customerAddress': '123 Đường ABC, Quận 1, TP.HCM',
      'deliveries': [
        {
          'deliveryNumber': 1,
          'status': 'Đã giao hàng',
          'statusColor': Colors.teal,
          'deliveryDate': '15/12/2024',
          'items': [
            {
              'productName': 'Rau cải ngọt',
              'deliveredQuantity': 2,
              'remainingQuantity': 0,
              'price': 40000,
            },
          ],
        },
      ],
    },
    {
      'orderId': 'DH001238',
      'status': 'Hoàn thành',
      'statusColor': Colors.green,
      'createdDate': '10/12/2024',
      'updatedDate': '14/12/2024',
      'productName': 'Xà lách lolo',
      'quantity': 3,
      'price': 75000,
      'customerName': 'Vòng Quốc Phi',
      'customerPhone': '0982912617',
      'customerAddress': '123 Đường ABC, Quận 1, TP.HCM',
      'deliveries': [
        {
          'deliveryNumber': 1,
          'status': 'Hoàn thành',
          'statusColor': Colors.green,
          'deliveryDate': '14/12/2024',
          'items': [
            {
              'productName': 'Xà lách lolo',
              'deliveredQuantity': 3,
              'remainingQuantity': 0,
              'price': 75000,
            },
          ],
        },
      ],
    },
  ];

  List<Map<String, dynamic>> getFilteredOrders(String status) {
    if (status == 'Tất cả') {
      return orders;
    }
    return orders.where((order) => order['status'] == status).toList();
  }

  void _navigateToOrderDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderDetailScreen(),
      ),
    );
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy đơn hàng'),
          content: Text('Bạn có chắc chắn muốn hủy đơn hàng $orderId?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã hủy đơn hàng $orderId'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử đơn hàng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.green.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.green.shade600,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Đã xác nhận'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Đã giao hàng'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('Tất cả'),
          _buildOrderList('Chờ xác nhận'),
          _buildOrderList('Đã xác nhận'),
          _buildOrderList('Đang giao'),
          _buildOrderList('Đã giao hàng'),
          _buildOrderList('Hoàn thành'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    List<Map<String, dynamic>> filteredOrders = getFilteredOrders(status);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
          // Order header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã đơn hàng: ${order['orderId']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: order['statusColor'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product info
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.eco,
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
                            order['productName'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Số lượng: ${order['quantity']} kg',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${order['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Order dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày tạo:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            order['createdDate'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày cập nhật:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            order['updatedDate'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    if (order['status'] == 'Chờ xác nhận') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelOrder(order['orderId']),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Hủy đơn',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _navigateToOrderDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(fontSize: 12),
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
}
import 'package:cfv_mobile/screens/order/order_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String selectedFilter = 'Tất cả';

  // Fake data matching your schema
  final List<Map<String, dynamic>> orders = [
    {
      "orderId": "01K21VPXEMPRC8280CHVYX0GAQ",
      "retailerId": "01JZ5PP990PVMQQZM5HPMFN2TA",
      "retailerName": "Organik Dalat",
      "gardenerId": "01JZ5PP9920ZWCRDHMW82MVHYS",
      "status": "DELIVERED",
      "totalAmount": 13200000,
      "shippingCost": 210000,
      "createdAt": "2025-08-01T07:32:29",
      "productTypeAmount": 2,
    },
    {
      "orderId": "01K13RRW4X9DZPPAB7XPJHXFD5",
      "retailerId": "01JZ5PP990PVMQQZM5HPMFN2TA",
      "retailerName": "Organik Dalat",
      "gardenerId": "01JZ5PP9920ZWCRDHMW82MVHYS",
      "status": "DELIVERED",
      "totalAmount": 8400000,
      "shippingCost": 100000,
      "createdAt": "2025-07-26T07:32:29",
      "productTypeAmount": 1,
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter == 'Tất cả') return orders;

    String filterStatus;
    switch (selectedFilter) {
      case 'Đã giao':
        filterStatus = 'DELIVERED';
        break;
      case 'Chờ xử lý':
        filterStatus = 'PENDING';
        break;
      case 'Đang xử lý':
        filterStatus = 'PROCESSING';
        break;
      case 'Đã hủy':
        filterStatus = 'CANCELLED';
        break;
      default:
        return orders;
    }

    return orders.where((order) => order['status'].toString() == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Danh sách đơn hàng',
          style: TextStyle(color: Colors.grey[800], fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [],
      ),
      body: Column(children: [Expanded(child: filteredOrders.isEmpty ? _buildEmptyState() : _buildOrderList())]),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final createdAt = DateTime.parse(order['createdAt']);
    final status = order['status'].toString();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'DELIVERED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'ĐÃ GIAO';
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'CHỜ XỬ LÝ';
        break;
      case 'PROCESSING':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        statusText = 'ĐANG XỬ LÝ';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'ĐÃ HỦY';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'KHÔNG XÁC ĐỊNH';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen()));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Order ID and Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${order['orderId'].toString().substring(0, 8)}...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Retailer Information
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['retailerName'],
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Product Information
              Row(
                children: [
                  Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${order['productTypeAmount']} loại sản phẩm',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Divider
              Container(height: 1, color: Colors.grey[200]),

              SizedBox(height: 12),

              // Amount Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phí vận chuyển', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        _formatCurrency(order['shippingCost'].toDouble()),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tổng tiền', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        _formatCurrency(order['totalAmount'].toDouble()),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Không có đơn hàng nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Thử điều chỉnh bộ lọc hoặc tạo đơn hàng mới',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Chi tiết đơn hàng', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('Mã đơn hàng: ${order['orderId']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Nhà bán lẻ: ${order['retailerName']}', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    'Tổng tiền: ${_formatCurrency(order['totalAmount'].toDouble())}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                  // Add more details as needed
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(amount);
  }
}

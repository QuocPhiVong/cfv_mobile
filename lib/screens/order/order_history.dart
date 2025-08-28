import 'package:cfv_mobile/screens/order/order_detail.dart';
import 'package:cfv_mobile/controller/oder_controller.dart';
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/responses/oder_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late final OderController orderController;
  int currentPage = 1;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    orderController = Get.find<OderController>();
    _initializeData();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    super.dispose();
  }

  Future<void> _initializeData() async {
    final accountId = _getAccountId();
    if (accountId.isNotEmpty) {
      await _loadOrders();
    } else {
      debugPrint('AccountId not found - user not authenticated');
      Get.snackbar(
        'Lỗi xác thực',
        'Vui lòng đăng nhập lại',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  String _getAccountId() {
    return Get.find<AuthenticationController>().currentUser?.accountId ?? '';
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    final accountId = _getAccountId();
    if (accountId.isEmpty) {
      debugPrint('AccountId not available');
      return;
    }

    try {
      if (refresh) {
        currentPage = 1;
      }
      await orderController.getOrders(accountId, currentPage, pageSize);
    } catch (e) {
      debugPrint('Error loading orders: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách đơn hàng',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[800]),
            onPressed: () => _loadOrders(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (orderController.isLoadingOrders.value && orderController.orders.isEmpty) {
                return _buildLoadingState();
              }

              return _buildOrderList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: () => _loadOrders(refresh: true),
      color: Colors.blue[700],
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: orderController.orders.length + (orderController.isLoadingOrders.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orderController.orders.length && orderController.isLoadingOrders.value) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!)),
              ),
            );
          }

          final order = orderController.orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!)),
          SizedBox(height: 16),
          Text('Đang tải danh sách đơn hàng...', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final createdAt = order.createdAt;
    final status = order.status ?? '';

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
      case 'DELIVERING':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        statusText = 'ĐANG GIAO';
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'ĐÃ HOÀN THÀNH';
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order.orderId ?? ''),
              settings: RouteSettings(arguments: {'orderId': order.orderId}),
            ),
          );
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
                          'Đơn hàng #${(order.orderId ?? '').length > 8 ? '${(order.orderId ?? '').substring(0, 8)}...' : order.orderId ?? ''}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt) : 'N/A',
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
                      order.retailerName ?? 'N/A',
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
                    '${order.productTypeAmount ?? 0} loại sản phẩm',
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
                        _formatCurrency((order.shippingCost ?? 0).toDouble()),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tổng tiền', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        _formatCurrency((order.totalAmount ?? 0).toDouble()),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ],
              ),
              if (order.status == 'PENDING') ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    final updatingStatusOrderId = orderController.updatingStatusOrderId.value;
                    final isUpdating = updatingStatusOrderId == order.orderId;
                    return OutlinedButton(
                      onPressed: () {
                        if (!isUpdating) {
                          _cancelOrder(order.orderId ?? '');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isUpdating
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(color: Colors.blue[700]!, strokeWidth: 2),
                            )
                          : Text('Hủy đơn', style: TextStyle(fontSize: 12)),
                    );
                  }),
                ),
              ],
              if (order.status == 'DELIVERED') ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    final updatingStatusOrderId = orderController.updatingStatusOrderId.value;
                    final isUpdating = updatingStatusOrderId == order.orderId;
                    return OutlinedButton(
                      onPressed: () {
                        if (!isUpdating) {
                          _completeOrder(order.orderId ?? '');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isUpdating
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(color: Colors.blue[700]!, strokeWidth: 2),
                            )
                          : Text('Hoàn thành', style: TextStyle(fontSize: 12)),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Không')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await orderController.updateStatusOrder(orderId, 'CANCELLED');
                _loadOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã hủy đơn hàng $orderId'), backgroundColor: Colors.red.shade600),
                );
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }

  void _completeOrder(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hoàn thành đơn hàng'),
          content: Text('Bạn có chắc chắn muốn hoàn thành đơn hàng $orderId?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Không')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await orderController.updateStatusOrder(orderId, 'COMPLETED');
                _loadOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã hoàn thành đơn hàng $orderId'), backgroundColor: Colors.green.shade600),
                );
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
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

  void _showOrderDetails(OrderModel order) {
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
                  Text(
                    'Mã đơn hàng: ${order.orderId ?? 'N/A'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('Nhà bán lẻ: ${order.retailerName ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    'Tổng tiền: ${_formatCurrency((order.totalAmount ?? 0).toDouble())}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
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

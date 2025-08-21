import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final List<CartResponse> orderItems;
  final double totalPrice;
  final int itemCount;
  final String customerName;
  final String customerPhone;
  final String deliveryMethod;
  final String? deliveryAddress;
  final String? orderNote;
  final String orderId;

  const OrderSuccessScreen({
    super.key,
    required this.orderItems,
    required this.totalPrice,
    required this.itemCount,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryMethod,
    this.deliveryAddress,
    this.orderNote,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(), // Remove back button
        title: const Text(
          'Đặt hàng thành công',
          style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Success Icon and Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                          child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 50),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Đặt hàng thành công!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cảm ơn bạn đã đặt hàng. Chúng tôi sẽ liên hệ với bạn sớm nhất để xác nhận đơn hàng.',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Mã đơn hàng: $orderId',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSectionCard(
                    title: 'Thông tin đơn hàng',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Khách hàng:', customerName),
                        const SizedBox(height: 8),
                        _buildInfoRow('Số điện thoại:', customerPhone),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Phương thức nhận hàng:',
                          deliveryMethod == 'pickup' ? 'Tự đến lấy' : 'Giao hàng tận nơi',
                        ),
                        if (deliveryMethod == 'delivery' && deliveryAddress != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('Địa chỉ giao hàng:', deliveryAddress!),
                        ],
                        if (orderNote != null && orderNote!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('Ghi chú:', orderNote!),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Order Items
                  _buildSectionCard(
                    title: 'Chi tiết sản phẩm ($itemCount sản phẩm)',
                    child: Column(children: orderItems.map((item) => _buildOrderItem(item)).toList()),
                  ),

                  const SizedBox(height: 16),

                  // Price Summary
                  _buildSectionCard(
                    title: 'Tóm tắt thanh toán',
                    child: Column(
                      children: [
                        _buildPriceRow('Tổng tiền hàng:', _formatPrice(totalPrice.toInt())),
                        if (deliveryMethod == 'delivery') ...[
                          const SizedBox(height: 8),
                          _buildPriceRow('Phí giao hàng:', 'Sẽ được xác nhận', isDeliveryFee: true),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                        ],
                        _buildTotalRow(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Thông tin quan trọng',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Chủ vườn sẽ liên hệ với bạn trong vòng 24 giờ để xác nhận đơn hàng\n'
                          '• Thời gian giao hàng dự kiến: 1-2 ngày làm việc\n'
                          '• Bạn có thể theo dõi trạng thái đơn hàng trong mục "Đơn hàng của tôi"',
                          style: TextStyle(fontSize: 14, color: Colors.blue.shade700, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Continue Shopping Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to home screen
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag, size: 20),
                          SizedBox(width: 8),
                          Text('Tiếp tục mua hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // View Order Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to order details/history screen
                        _showOrderDetails(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade600,
                        side: BorderSide(color: Colors.green.shade600, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 20),
                          SizedBox(width: 8),
                          Text('Xem đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(CartResponse item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.eco, color: Colors.green.shade600, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.cartItems?.first.productName ?? 'Sản phẩm không rõ',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(item.gardenerName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.cartItems?.first.quantity} kg × ${item.cartItems?.first.price} VNĐ',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      '${_formatPrice(item.totalPrice.toInt())} VNĐ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade600),
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

  Widget _buildPriceRow(String label, String value, {bool isDeliveryFee = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        Text(
          isDeliveryFee ? value : '$value VNĐ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tổng thanh toán:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_formatPrice(totalPrice.toInt())} VNĐ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade600),
            ),
            if (deliveryMethod == 'delivery')
              Text(
                '+ phí giao hàng',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
              ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chi tiết đơn hàng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mã đơn hàng: $orderId',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Chờ xác nhận',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ngày đặt: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Trạng thái đơn hàng:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          _buildOrderStatus(),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Về trang chủ'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderStatus() {
    return Column(
      children: [
        _buildStatusStep('Đơn hàng đã được tạo', true, true),
        _buildStatusStep('Chờ xác nhận từ chủ vườn', false, false),
        _buildStatusStep('Đang chuẩn bị hàng', false, false),
        _buildStatusStep('Đang giao hàng', false, false),
        _buildStatusStep('Đã hoàn thành', false, false),
      ],
    );
  }

  Widget _buildStatusStep(String title, bool isCompleted, bool isActive) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green.shade600
                : isActive
                ? Colors.orange.shade400
                : Colors.grey.shade300,
          ),
          child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
              color: isCompleted
                  ? Colors.green.shade700
                  : isActive
                  ? Colors.orange.shade700
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

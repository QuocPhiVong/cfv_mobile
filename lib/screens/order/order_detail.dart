import 'package:cfv_mobile/controller/app_controller.dart';
import 'package:cfv_mobile/controller/order_detail_controller.dart';
import 'package:cfv_mobile/controller/review_controller.dart';
import 'package:cfv_mobile/data/responses/order_detail_response.dart';
import 'package:cfv_mobile/screens/order/create_review.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final controller = Get.put(OrderDetailController());
  final reviewController = Get.find<ReviewController>();

  @override
  void initState() {
    super.initState();
    controller.loadOrderDetail(widget.orderId).whenComplete(() {
      reviewController.getReview(
        controller.order.value?.retailerId ?? '',
        controller.order.value?.orderId ?? '',
        controller.order.value?.orderDetails.first.orderDetailId ?? '',
      );
    });
    controller.loadOrderDeliveries(widget.orderId);
  }

  // Track which delivery items are expanded
  Set<int> expandedDeliveries = {};

  // // Sample order data
  // final Map<String, dynamic> orderData = {
  //   'orderId': 'DH001234',
  //   'status': 'Đang giao',
  //   'statusColor': Colors.blue,
  //   'createdDate': '15/12/2024',
  //   'updatedDate': '16/12/2024',
  //   'gardenName': 'Vườn Rau Sạch Phi',
  //   'customerPhone': '0982912617',
  //   'customerAddress': '123 Đường ABC, Quận 1, TP.HCM',
  //   'paymentMethod': 'Chuyển khoản',
  //   'shippingCost': 15000,
  //   'shippingAddress': '456 Đường XYZ, Quận 2, TP.HCM',
  //   'totalAmount': 125000,
  //   'products': [
  //     {
  //       'name': 'Xà lách xoong tươi',
  //       'quantity': 2,
  //       'price': 25000,
  //       'image': 'eco',
  //       'totalQuantity': 2,
  //       'deliveredQuantity': 2,
  //       'remainingQuantity': 0,
  //     },
  //     {
  //       'name': 'Rau muống hữu cơ',
  //       'quantity': 3,
  //       'price': 20000,
  //       'image': 'eco',
  //       'totalQuantity': 3,
  //       'deliveredQuantity': 1,
  //       'remainingQuantity': 2,
  //     },
  //     {
  //       'name': 'Cải thìa baby',
  //       'quantity': 1,
  //       'price': 35000,
  //       'image': 'eco',
  //       'totalQuantity': 1,
  //       'deliveredQuantity': 1,
  //       'remainingQuantity': 0,
  //     },
  //   ],
  //   'deliveries': [
  //     {
  //       'deliveryCode': 'GH001',
  //       'notes': 'Giao hàng buổi sáng',
  //       'status': 'Đã giao',
  //       'statusColor': Colors.green,
  //       'deliveryDate': '16/12/2024',
  //       'items': [
  //         {'productName': 'Xà lách xoong tươi', 'quantity': 2, 'price': 50000},
  //         {'productName': 'Rau muống hữu cơ', 'quantity': 1, 'price': 20000},
  //       ],
  //     },
  //     {
  //       'deliveryCode': 'GH002',
  //       'notes': 'Giao hàng buổi chiều',
  //       'status': 'Đang giao',
  //       'statusColor': Colors.blue,
  //       'deliveryDate': '17/12/2024',
  //       'items': [
  //         {'productName': 'Rau muống hữu cơ', 'quantity': 2, 'price': 40000},
  //         {'productName': 'Cải thìa baby', 'quantity': 1, 'price': 35000},
  //       ],
  //     },
  //   ],
  // };

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
          'Chi tiết đơn hàng',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.order.value == null) {
          return const Center(child: Text('Không tìm thấy đơn hàng'));
        }

        final order = controller.order.value!;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Order basic information
              _buildOrderInfoCard(order),

              const SizedBox(height: 16),

              // Customer information
              _buildCustomerInfoCard(order),

              const SizedBox(height: 16),

              // Products list
              _buildProductsCard(order),

              // const SizedBox(height: 16),

              // Order tracking section
              _buildOrderTrackingCard(),

              const SizedBox(height: 16),

              // Order summary
              _buildOrderSummaryCard(order),

              // Create review section
              Obx(
                () =>
                    (controller.order.value?.status != "DELIVERED" ||
                        reviewController.isLoadingReview.value ||
                        reviewController.review.value?.reviewId != null)
                    ? const SizedBox.shrink()
                    : _buildCreateReviewSection(
                        order.retailerId,
                        order.orderId,
                        order.orderDetails.first.orderDetailId,
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfoCard(OrderDetailResponse order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(color: order.statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Mã đơn hàng:', order.orderId),
          const SizedBox(height: 8),
          _buildInfoRow('Ngày tạo:', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order.createdAt))),
          const SizedBox(height: 8),
          _buildInfoRow('Phương thức thanh toán:', order.paymentMethod),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Chi phí vận chuyển:',
            '${order.shippingCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Địa chỉ vận chuyển:', order.shippingAddress),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(OrderDetailResponse order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Thông tin chủ vườn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tên vườn:', order.accountName),
          const SizedBox(height: 8),
          _buildInfoRow('Số điện thoại:', order.phoneNumber),
        ],
      ),
    );
  }

  Widget _buildProductsCard(OrderDetailResponse order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Sản phẩm đặt hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ...order.orderDetails.map<Widget>((product) {
            final depositPercentage = AppController.getProductDepositPercentage(product.productId ?? '');
            final quantity = product.quantity ?? 0;
            final price = product.price ?? 0;
            final deposit = (price * quantity * depositPercentage / 100).toInt();
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                              product.productName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ/kg',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tổng: ${product.quantity} kg',
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Đã giao: ${product.deliveredQuantity} kg',
                            style: TextStyle(fontSize: 11, color: Colors.green.shade600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Còn lại: ${product.quantity - product.deliveredQuantity} kg',
                            style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.orange.shade600, size: 16),
                          const SizedBox(width: 8),
                          const Text('Đặt cọc trước:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            '$depositPercentage%',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.payments, color: Colors.orange.shade600, size: 16),
                          const SizedBox(width: 8),
                          const Text('Số tiền đặt cọc:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            '${_formatPrice(deposit)} VNĐ',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Trạng thái gieo trồng:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      {
                            "PREORDEROPEN": "Mở đặt cọc",
                            "PLANTING": "Đang trồng",
                            "HARVESTING": "Thu hoạch",
                            "PROCESSING": "Đóng gói",
                            "READYFORSALE": "Có hàng",
                            "HARVESTFAILED": "Mất mùa",
                          }[product.harvestStatus] ??
                          "N/A",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    // Handle contract download
                    _downloadContract(order.contractImage);
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Hợp đồng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.download, color: Colors.blue.shade600, size: 16),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildOrderTrackingCard() {
    return Obx(() {
      if (controller.isLoadingDeliveries.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.orderDeliveries.value == null) {
        return const SizedBox.shrink();
      }

      final deliveries = controller.orderDeliveries.value!.deliveries;

      if (deliveries.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
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
            const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ...deliveries.map<Widget>((delivery) {
              int deliveryIndex = deliveries.indexOf(delivery);
              bool isExpanded = expandedDeliveries.contains(deliveryIndex);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            expandedDeliveries.remove(deliveryIndex);
                          } else {
                            expandedDeliveries.add(deliveryIndex);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: delivery.deliveryStatusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    delivery.deliveryStatus,
                                    style: TextStyle(
                                      color: delivery.deliveryStatusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Mã GH: ${delivery.orderDeliveryId}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(DateTime.parse(delivery.deliveryDate)),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 8),
                                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey.shade600),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Ghi chú: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    delivery.note ?? '',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 1),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: delivery.orderDeliveryDetails.map<Widget>((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Số lượng: ${item.quantity} ${item.productUnit}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                      ),
                                      Text(
                                        '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildOrderSummaryCard(OrderDetailResponse order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Tổng kết đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Text(
                '${order.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
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
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateReviewSection(String retailerId, String orderId, String orderDetailId) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CreateReviewScreen(retailerId: retailerId, orderId: orderId, detailId: orderDetailId));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 24),
            const SizedBox(width: 8),
            Text(
              'Đánh giá sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadContract(String? url) async {
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}

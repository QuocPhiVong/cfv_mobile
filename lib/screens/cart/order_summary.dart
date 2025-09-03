import 'package:cfv_mobile/controller/app_controller.dart';
import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/controller/cart_controller.dart';
import 'package:cfv_mobile/controller/oder_controller.dart';
import 'package:cfv_mobile/data/responses/cart_response.dart';
import 'package:cfv_mobile/screens/cart/address_selection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'order_success.dart';

class OrderSummaryScreen extends StatefulWidget {
  final List<CartResponse> orderItems;
  final double totalPrice;
  final int itemCount;

  const OrderSummaryScreen({super.key, required this.orderItems, required this.totalPrice, required this.itemCount});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String selectedDeliveryMethod = 'card';
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final AuthenticationController _authController = Get.find<AuthenticationController>();
  final OderController _oderController = Get.find<OderController>();
  final CartController _cartController = Get.find<CartController>();

  final List<File> _selectedContract = [];
  final List<String> _contractFileName = [];
  List<String> uploadedImageUrl = [];

  final Map<String, double> _depositPercentages = {};

  // Delivery fee
  final int deliveryFee = 15000;

  @override
  void initState() {
    super.initState();
    _oderController.getAddress(_authController.currentUser?.accountId ?? '').then((value) {
      _addressController.text = _oderController.addresses.first.addressLine ?? '';
      setState(() {});
    });
    // Pre-fill some default values
    _nameController.text = _authController.currentUser?.name ?? '';
    _phoneController.text = _authController.currentUser?.phoneNumber ?? '';

    for (var item in widget.orderItems) {
      _depositPercentages[item.gardenerName] = 20.0;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Generate order ID
  String _generateOrderId() {
    final now = DateTime.now();
    return 'DH${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalWithDelivery = widget.totalPrice;

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
          'Xác nhận đơn hàng',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information
                  _buildSectionCard(
                    title: 'Thông tin khách hàng',
                    child: Column(
                      children: [
                        _buildTextField(controller: _nameController, label: 'Họ và tên', icon: Icons.person),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildAddressField(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Order Items
                  _buildSectionCard(
                    title: 'Chi tiết đơn hàng (${widget.itemCount} sản phẩm)',
                    child: Column(children: widget.orderItems.map((item) => _buildOrderItem(item)).toList()),
                  ),
                  const SizedBox(height: 16),
                  // Contract Upload section
                  _buildSectionCard(
                    title: 'Tải lên hợp đồng',
                    child: Column(
                      children: [
                        // Contract files display
                        if (_selectedContract.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.upload_file, color: Colors.grey.shade500, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Chưa có tệp nào được chọn',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đã chọn ${_selectedContract.length} tệp hợp đồng',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(_selectedContract.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.description, color: Colors.blue.shade600, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _contractFileName[index],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Tệp hợp đồng',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeFile(index),
                                        icon: Icon(Icons.close, color: Colors.red.shade400, size: 20),
                                        tooltip: 'Xóa tệp',
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        const SizedBox(height: 16),
                        // Upload button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _pickContractFile,
                            icon: const Icon(Icons.add),
                            label: Text(_selectedContract.isEmpty ? 'Chọn tệp hợp đồng' : 'Thêm tệp hợp đồng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Information message
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vui lòng tải lên hợp đồng để hoàn tất đơn hàng. Chấp nhận các định dạng: PDF, DOC, DOCX',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Order Summary
                  _buildSectionCard(
                    title: 'Tóm tắt đơn hàng',
                    child: Column(
                      children: [
                        _buildSummaryRow('Tổng tiền hàng:', _formatPrice(widget.totalPrice.toInt())),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Phí giao hàng:',
                          'Sẽ được chủ vườn xác nhận sau khi tạo đơn',
                          isDeliveryFee: true,
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildTotalRow(true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Bottom confirm button
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
              child: ElevatedButton(
                onPressed: () => _confirmOrder(totalWithDelivery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.green.shade200,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 20),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Xác nhận đặt hàng',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return GestureDetector(
      onTap: () async {
        final selectedAddress = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => AddressListScreen(selectedAddress: _addressController.text)),
        );

        if (selectedAddress != null) {
          setState(() {
            _addressController.text = selectedAddress;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.home, color: Colors.green.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Địa chỉ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(
                    _addressController.text.isEmpty ? 'Chọn địa chỉ giao hàng' : _addressController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _addressController.text.isEmpty ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickContractFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // show loading
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final imageUrls = await _oderController.uploadImage(result.files);
        print('image url ==> $imageUrls');

        Navigator.of(context).pop();

        if (imageUrls.isNotEmpty) {
          setState(() {
            // Add new files to existing ones
            _selectedContract.addAll(result.files.map((e) => File(e.path!)));
            _contractFileName.addAll(result.files.map((e) => e.name));
            uploadedImageUrl.addAll(imageUrls);
          });
          // show snackbar success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tải lên ${result.files.length} tệp hợp đồng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // show snackbar error
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tải lên hợp đồng thất bại'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi chọn tệp: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedContract.removeAt(index);
      _contractFileName.removeAt(index);
      uploadedImageUrl.removeAt(index);
    });
  }

  void _confirmOrder(double totalPrice) {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập họ và tên');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập số điện thoại');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng chọn địa chỉ giao hàng');
      return;
    }

    // Validate contract upload
    if (_selectedContract.isEmpty) {
      _showErrorMessage('Vui lòng tải lên ít nhất một tệp hợp đồng');
      return;
    }

    // Show order confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Xác nhận đặt hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn có chắc chắn muốn đặt hàng với thông tin sau:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách hàng: ${_nameController.text}'),
                    Text('Số điện thoại: ${_phoneController.text}'),
                    Text('Phương thức: ${selectedDeliveryMethod == 'card' ? 'Thanh toán thẻ' : 'COD'}'),
                    Text('Địa chỉ: ${_addressController.text}'),
                    Text(
                      'Hợp đồng: ${_contractFileName.isNotEmpty ? _contractFileName.join(', ') : 'Chưa có tệp hợp đồng'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tổng tiền: ${_formatPrice(totalPrice.toInt())} VNĐ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _processOrder() {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Clear cart
    _oderController
        .createOder(
          _authController.currentUser?.accountId ?? '',
          selectedDeliveryMethod,
          widget.orderItems,
          uploadedImageUrl,
        )
        .then((value) {
          if (value == true) {
            _cartController.deleteCart(_authController.currentUser?.accountId ?? '');
            _navigateToSuccessScreen();
          } else {
            _showErrorMessage('Đặt hàng thất bại');
            Navigator.of(context).pop();
          }
        });
  }

  void _navigateToSuccessScreen() {
    final orderId = _generateOrderId();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          orderItems: widget.orderItems,
          totalPrice: widget.totalPrice,
          itemCount: widget.itemCount,
          customerName: _nameController.text,
          customerPhone: _phoneController.text,
          deliveryMethod: selectedDeliveryMethod,
          deliveryAddress: _addressController.text,
          orderNote: _noteController.text.isNotEmpty ? _noteController.text : null,
          orderId: orderId,
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade600),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOrderItem(CartResponse item) {
    final depositPercentage = AppController.getProductDepositPercentage(item.cartItems?.first.productId ?? '');
    final quantity = item.cartItems?.first.quantity ?? 0;
    final price = item.cartItems?.first.price ?? 0;
    final deposit = (price * quantity * depositPercentage / 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
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
                      item.gardenerName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.cartItems!.first.productName ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${item.cartItems?.first.quantity} kg × ${item.cartItems?.first.price}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
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
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isDeliveryFee = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            isDeliveryFee ? value : '$value VNĐ',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green.shade600 : Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(bool hasDelivery) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Tổng thanh toán:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatPrice(widget.totalPrice.toInt())} VNĐ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                textAlign: TextAlign.right,
              ),
              if (hasDelivery)
                Text(
                  '+ phí giao hàng',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                  textAlign: TextAlign.right,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

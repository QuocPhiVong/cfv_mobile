import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/repositories/oder_repository.dart';
import 'package:cfv_mobile/data/responses/order_detail_response.dart';
import 'package:cfv_mobile/data/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class OrderDetailController extends GetxController {
  static OrderDetailController get instance => Get.find();

  final OderRepository _orderRepository = Get.put(OderRepository());

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Order detail data
  final Rx<OrderDetailResponse?> order = Rx<OrderDetailResponse?>(null);

  // Order ID
  String? _orderId;

  @override
  void onInit() {
    super.onInit();
    // Get orderId from arguments if available
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _orderId = args['orderId']?.toString();
      if (_orderId != null) {
        loadOrderDetail(_orderId!);
      }
    }
  }

  @override
  void onReady() {
    debugPrint('OrderDetailController onReady: Controller initialized.');
    super.onReady();
  }

  /// Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Load order detail by ID
  Future<bool> loadOrderDetail(String orderId) async {
    try {
      clearMessages();
      isLoading.value = true;
      _orderId = orderId;

      final accountId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';

      final response = await _orderRepository.getOrderDetail(accountId, orderId);

      order.value = response;
      debugPrint('Order detail loaded successfully: ${response.orderId}');
      return true;
    } catch (e) {
      debugPrint('Load order detail error in controller: $e');
      errorMessage.value = 'Không thể tải thông tin đơn hàng. Vui lòng thử lại.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh order detail
  Future<void> refreshOrderDetail() async {
    if (_orderId != null) {
      await loadOrderDetail(_orderId!);
    }
  }

  /// Cancel order with reason
  Future<bool> cancelOrder({
    required String cancellationReason,
  }) async {
    try {
      if (_orderId == null) {
        errorMessage.value = 'Không tìm thấy ID đơn hàng.';
        return false;
      }

      clearMessages();
      isUpdating.value = true;
      
      final isSuccess = await _orderRepository.updateStatusOrder(_orderId!, 'CANCELLED');

      if (isSuccess) {
        successMessage.value = 'Đơn hàng đã được hủy thành công!';
        debugPrint('Order cancelled successfully');
        refreshOrderDetail();
        return true;
      } else {
        errorMessage.value = 'Có lỗi xảy ra khi hủy đơn hàng. Vui lòng thử lại.';
        debugPrint('Failed to cancel order');
        return false;
      }
    } catch (e) {
      debugPrint('Cancel order error in controller: $e');
      errorMessage.value = 'Có lỗi xảy ra khi hủy đơn hàng. Vui lòng thử lại.';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String status) async {
    try {
      if (_orderId == null) {
        errorMessage.value = 'Không tìm thấy ID đơn hàng.';
        return false;
      }

      clearMessages();
      isUpdating.value = true;
      
      final isSuccess = await _orderRepository.updateStatusOrder(_orderId!, status);

      if (isSuccess) {
        successMessage.value = 'Trạng thái đơn hàng đã được cập nhật!';
        debugPrint('Order status updated successfully to: $status');
        refreshOrderDetail();
        return true;
      } else {
        errorMessage.value = 'Có lỗi xảy ra khi cập nhật trạng thái. Vui lòng thử lại.';
        debugPrint('Failed to update order status');
        return false;
      }
    } catch (e) {
      debugPrint('Update order status error in controller: $e');
      errorMessage.value = 'Có lỗi xảy ra khi cập nhật trạng thái. Vui lòng thử lại.';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get order status display text
  String getStatusDisplayText() {
    switch (order.value?.status.toLowerCase()) {
      case 'pending':
        return 'CHỜ XỬ LÝ';
      case 'confirmed':
        return 'ĐÃ XÁC NHẬN';
      case 'processing':
        return 'ĐANG XỬ LÝ';
      case 'shipping':
        return 'ĐANG GIAO HÀNG';
      case 'delivered':
        return 'ĐÃ GIAO HÀNG';
      case 'cancelled':
        return 'ĐÃ HỦY';
      case 'completed':
        return 'HOÀN THÀNH';
      default:
        return 'KHÔNG XÁC ĐỊNH';
    }
  }

  /// Get order status color
  String getStatusColor() {
    switch (order.value?.status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'confirmed':
        return 'blue';
      case 'processing':
        return 'blue';
      case 'shipping':
        return 'purple';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'completed':
        return 'green';
      default:
        return 'grey';
    }
  }

  /// Get payment method display text
  String getPaymentMethodDisplayText() {
    switch (order.value?.paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tiền mặt';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'debit_card':
        return 'Thẻ ghi nợ';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'e_wallet':
        return 'Ví điện tử';
      default:
        return order.value?.paymentMethod ?? 'Không xác định';
    }
  }

  /// Calculate total order amount including shipping
  int getTotalOrderAmount() {
    final order = this.order.value;
    if (order == null) return 0;
    return order.totalAmount + order.shippingCost;
  }

  /// Get delivery status display text for order detail item
  String getDeliveryStatusDisplayText(String deliveryStatus) {
    switch (deliveryStatus.toLowerCase()) {
      case 'pending':
        return 'CHỜ GIAO HÀNG';
      case 'shipping':
        return 'ĐANG GIAO HÀNG';
      case 'delivered':
        return 'ĐÃ GIAO HÀNG';
      case 'failed':
        return 'GIAO HÀNG THẤT BẠI';
      default:
        return 'KHÔNG XÁC ĐỊNH';
    }
  }

  /// Get delivery status color for order detail item
  String getDeliveryStatusColor(String deliveryStatus) {
    switch (deliveryStatus.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'shipping':
        return 'blue';
      case 'delivered':
        return 'green';
      case 'failed':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  void onClose() {
    debugPrint('OrderDetailController onClose: Cleaning up controller.');
    super.onClose();
  }
}

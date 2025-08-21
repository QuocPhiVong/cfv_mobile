import 'package:cfv_mobile/data/repositories/appointment_repository.dart';
import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:cfv_mobile/data/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AppointmentDetailController extends GetxController {
  static AppointmentDetailController get instance => Get.find();

  final AppointmentRepository _appointmentRepository = Get.put(AppointmentRepository());

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Appointment detail data
  final Rx<AppointmentData?> appointment = Rx<AppointmentData?>(null);

  // Appointment ID
  String? _appointmentId;

  @override
  void onInit() {
    super.onInit();
    // Get appointmentId from arguments if available
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _appointmentId = args['appointmentId']?.toString();
      if (_appointmentId != null) {
        loadAppointmentDetail(_appointmentId!);
      }
    }
  }

  @override
  void onReady() {
    debugPrint('AppointmentDetailController onReady: Controller initialized.');
    super.onReady();
  }

  /// Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Load appointment detail by ID
  Future<bool> loadAppointmentDetail(String appointmentId) async {
    try {
      clearMessages();
      isLoading.value = true;
      _appointmentId = appointmentId;

      final response = await _appointmentRepository.getAppointmentById(appointmentId);

      if (response.success && response.data != null) {
        appointment.value = response.data;
        debugPrint('Appointment detail loaded successfully: ${response.data?.subject}');
        return true;
      } else {
        errorMessage.value = response.message;
        debugPrint('Failed to load appointment detail: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Load appointment detail error in controller: $e');
      errorMessage.value = 'Không thể tải thông tin lịch hẹn. Vui lòng thử lại.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh appointment detail
  Future<void> refreshAppointmentDetail() async {
    if (_appointmentId != null) {
      await loadAppointmentDetail(_appointmentId!);
    }
  }

  /// Cancel appointment with reason
  Future<bool> cancelAppointment({required String cancellationReason}) async {
    try {
      if (_appointmentId == null) {
        errorMessage.value = 'Không tìm thấy ID lịch hẹn.';
        return false;
      }

      clearMessages();
      isUpdating.value = true;

      final isSuccess = await _appointmentRepository.cancelAppointment(
        _appointmentId!,
        cancellationReason: cancellationReason,
        cancelledBy: 'retailer',
      );

      if (isSuccess) {
        successMessage.value = 'Lịch hẹn đã được hủy thành công!';
        debugPrint('Appointment cancelled successfully');
        refreshAppointmentDetail();
        return true;
      } else {
        errorMessage.value = 'Có lỗi xảy ra khi hủy lịch hẹn. Vui lòng thử lại.';
        debugPrint('Failed to cancel appointment: $isSuccess');
        return false;
      }
    } catch (e) {
      debugPrint('Cancel appointment error in controller: $e');
      errorMessage.value = 'Có lỗi xảy ra khi hủy lịch hẹn. Vui lòng thử lại.';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get appointment status display text
  String getStatusDisplayText() {
    switch (appointment.value?.status?.toLowerCase()) {
      case 'confirmed':
        return 'ĐÃ XÁC NHẬN';
      case 'pending':
        return 'CHỜ XÁC NHẬN';
      case 'cancelled':
        return 'ĐÃ HỦY';
      default:
        return 'KHÔNG XÁC ĐỊNH';
    }
  }

  /// Get appointment status color
  String getStatusColor() {
    switch (appointment.value?.status?.toLowerCase()) {
      case 'confirmed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Get cancellation display text
  String getCancelledByDisplayText() {
    switch (appointment.value?.cancelledBy?.toLowerCase()) {
      case 'retailer':
        return 'Nhà bán lẻ';
      case 'gardener':
        return 'Thợ làm vườn';
      case 'customer':
        return 'Khách hàng';
      default:
        return 'Không xác định';
    }
  }

  @override
  void onClose() {
    debugPrint('AppointmentDetailController onClose: Cleaning up controller.');
    super.onClose();
  }
}

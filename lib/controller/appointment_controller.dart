import 'package:cfv_mobile/controller/auth_controller.dart';
import 'package:cfv_mobile/data/repositories/appointment_repository.dart';
import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AppointmentController extends GetxController {
  static AppointmentController get instance => Get.find();

  final AppointmentRepository _appointmentRepository = Get.put(AppointmentRepository());

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Appointment data
  final RxList<AppointmentData> appointments = <AppointmentData>[].obs;

  @override
  void onReady() {
    debugPrint('AppointmentController onReady: Initializing appointment controller.');
    super.onReady();
  }

  /// Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Get appointments list
  Future<void> getAppointments({
    bool refresh = false,
    String? status,
  }) async {
   final accountId = Get.find<AuthenticationController>().currentUser?.accountId ?? '';
    try {
      clearMessages();
      
      if (refresh) {
        appointments.clear();
      }

      isLoading.value = true;

      final response = await _appointmentRepository.getAppointments(accountId);

      if (response.success && response.appointments != null) {
        // With the new API format, we get all appointments at once
        appointments.value = response.appointments!;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      debugPrint('Get appointments error in controller: $e');
      errorMessage.value = 'Không thể tải danh sách lịch hẹn.';
    } finally {
      isLoading.value = false;
    }
  }
}
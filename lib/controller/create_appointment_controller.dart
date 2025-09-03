import 'package:cfv_mobile/data/repositories/appointment_repository.dart';
import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class CreateAppointmentController extends GetxController {
  static CreateAppointmentController get instance => Get.find();

  final AppointmentRepository _appointmentRepository = Get.put(AppointmentRepository());

  // Observable states
  final RxBool isCreating = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

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

  /// Create a new appointment
  Future<bool> createAppointment({
    required String subject,
    required String description,
    required DateTime appointmentDate,
    required int duration,
    required String appointmentType,
    required String gardenerId,
    required String retailerId,
    required String location,
  }) async {
    try {
      clearMessages();
      isCreating.value = true;

      final request = CreateAppointmentRequest(
        subject: subject,
        description: description,
        appointmentDate: appointmentDate,
        duration: duration,
        appointmentType: appointmentType,
        gardenerId: gardenerId,
        retailerId: retailerId,
        location: location,
      );

      final isSuccess = await _appointmentRepository.createAppointment(request);

      if (isSuccess) {
        successMessage.value = 'Lịch hẹn đã được tạo thành công!';
        return true;
      } else {
        errorMessage.value = 'Có lỗi xảy ra khi tạo lịch hẹn. Vui lòng thử lại.';
        return false;
      }
    } catch (e) {
      debugPrint('Create appointment error in controller: $e');
      errorMessage.value = 'Có lỗi xảy ra khi tạo lịch hẹn. Vui lòng thử lại.';
      return false;
    } finally {
      isCreating.value = false;
    }
  }
}

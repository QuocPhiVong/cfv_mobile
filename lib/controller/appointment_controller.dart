import 'package:cfv_mobile/data/repositories/appointment_repository.dart';
import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AppointmentController extends GetxController {
  static AppointmentController get instance => Get.find();

  final AppointmentRepository _appointmentRepository = Get.put(AppointmentRepository());

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Appointment data
  final Rx<AppointmentData?> currentAppointment = Rx<AppointmentData?>(null);
  final RxList<AppointmentData> appointments = <AppointmentData>[].obs;
  final RxList<String> availableTimeSlots = <String>[].obs;

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

      final request = CreateAppointmentRequest
      (
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
        await getAppointments(refresh: true);
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

  /// Get appointments list
  Future<void> getAppointments({
    bool refresh = false,
    String? status,
  }) async {
    try {
      clearMessages();
      
      if (refresh) {
        appointments.clear();
      }

      isLoading.value = true;

      final response = await _appointmentRepository.getAppointments();

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

  /// Get appointment by ID
  Future<bool> getAppointmentById(String appointmentId) async {
    try {
      clearMessages();
      isLoading.value = true;

      final response = await _appointmentRepository.getAppointmentById(appointmentId);

      if (response.success && response.data != null) {
        currentAppointment.value = response.data;
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      debugPrint('Get appointment by ID error in controller: $e');
      errorMessage.value = 'Không thể tải thông tin lịch hẹn.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter appointments by status
  List<AppointmentData> getAppointmentsByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return appointments;
    }
    return appointments.where((apt) => apt.status?.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Get appointment count by status
  int getAppointmentCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return appointments.length;
    }
    return appointments.where((apt) => apt.status?.toLowerCase() == status.toLowerCase()).length;
  }
}

extension AppointmentDataExtension on AppointmentData {
  AppointmentData copyWith({
    String? id,
    String? appointmentId,
    String? subject,
    String? description,
    DateTime? appointmentDate,
    String? duration,
    String? appointmentType,
    String? status,
    String? location,
    String? gardenName,
    String? phone,
    String? address,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerId,
    String? gardenId,
    String? retailerId,
  }) {
    return AppointmentData(
      appointmentId: appointmentId ?? this.appointmentId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      duration: duration ?? this.duration,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      location: location ?? this.location,
      gardenName: gardenName ?? this.gardenName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerId: customerId ?? this.customerId,
      gardenerId: gardenId ?? this.gardenerId,
      retailerId: retailerId ?? this.retailerId,
    );
  }
}

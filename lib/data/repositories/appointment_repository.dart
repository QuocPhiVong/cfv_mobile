import 'package:cfv_mobile/data/services/api_services.dart';
import 'package:cfv_mobile/data/services/storage_service.dart';
import 'package:cfv_mobile/data/responses/appointment_response.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AppointmentRepository extends GetxController {
  static AppointmentRepository get instance => Get.find();

  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    debugPrint('AppointmentRepository onReady: Initializing appointment repository.');
    super.onReady();
  }

  /// Create a new appointment
  /// Returns AppointmentResponse with created appointment data
  Future<bool> createAppointment(CreateAppointmentRequest request) async {
    try {
      debugPrint('Creating appointment: ${request.toJson()}');

      final response = await _apiService.post(
        '/appointments',
        data: request.toJson(),
      );

     debugPrint('Create appointment response: ${response.data}');
      return true;
    } catch (e) {
      debugPrint('Create appointment error: $e');
      return false;
    }
  }

  /// Get appointments list for the current user
  /// Returns AppointmentResponse with list of appointments
  Future<AppointmentsResponse> getAppointments(String accountId) async {
    try {

      final response = await _apiService.get(
        '/accounts/$accountId/appointments',
      );

      debugPrint('Get appointments response: ${response.data}');
      return AppointmentsResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('Get appointments error: $e');
      return AppointmentsResponse(
        success: false,
        message: e.toString().contains('Exception: ') 
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Không thể tải danh sách lịch hẹn.',
        appointments: [],
      );
    }
  }

  /// Get a specific appointment by ID
  /// Returns AppointmentDetailResponse with appointment data
  Future<AppointmentDetailResponse> getAppointmentById(String appointmentId) async {
    try {
      debugPrint('Fetching appointment: $appointmentId');
      
      final response = await _apiService.get('/appointments/$appointmentId');

      debugPrint('Get appointment by ID response: ${response.data}');
      return AppointmentDetailResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('Get appointment by ID error: $e');
      return AppointmentDetailResponse(
        success: false,
        message: e.toString().contains('Exception: ') 
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Không thể tải thông tin lịch hẹn.',
      );
    }
  }

  /// Cancel an appointment
  /// Returns AppointmentDetailResponse indicating success or failure
  Future<bool> cancelAppointment(
    String appointmentId,
    {required String cancellationReason, required String cancelledBy}
  ) async {
    try {
      debugPrint('Cancelling appointment $appointmentId: $cancellationReason $cancelledBy');
      
      final response = await _apiService.patch(
        '/appointments/$appointmentId/cancel',
        data: {
          'cancellationReason': cancellationReason,
          'cancelledBy': cancelledBy,
        },
      );

      debugPrint('Cancel appointment response: ${response.data}');
      return true;
    } catch (e) {
      debugPrint('Cancel appointment error: $e');
      return false;
    }
  }
}

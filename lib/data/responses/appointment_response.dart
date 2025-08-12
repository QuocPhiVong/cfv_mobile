class AppointmentsResponse {
  final bool success;
  final String message;
  final List<AppointmentData>? appointments;

  AppointmentsResponse({
    required this.success,
    required this.message,
    this.appointments,
  });

  factory AppointmentsResponse.fromJson(dynamic json) {
    if (json is List) {
      final appointmentsList = json
          .map((item) => AppointmentData.fromJson(item))
          .toList();
      return AppointmentsResponse(
        success: true,
        message: 'Success',
        appointments: appointmentsList,
      );
    }

    return AppointmentsResponse(
      success: false,
      message: 'Invalid response format',
    );
  }
}

class AppointmentDetailResponse {
  final bool success;
  final String message;
  final AppointmentData? data;

  AppointmentDetailResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AppointmentDetailResponse.fromJson(dynamic json) {
    // Handle direct appointment object response
    if (json is Map<String, dynamic>) {
      // Check if it contains appointment fields
      if (json.containsKey('appointmentId')) {
        return AppointmentDetailResponse(
          success: true,
          message: 'Success',
          data: AppointmentData.fromJson(json),
        );
      }
      
      // Handle error response format
      return AppointmentDetailResponse(
        success: false,
        message: json['message'] ?? json['error'] ?? 'Unknown error occurred',
      );
    }

    return AppointmentDetailResponse(
      success: false,
      message: 'Invalid response format',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AppointmentData {
  final String? appointmentId;
  final String? subject;
  final String? description;
  final DateTime? appointmentDate;
  final String? duration;
  final String? appointmentType;
  final String? status;
  final String? location;
  final String? gardenName;
  final String? phone;
  final String? address;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerId;
  final String? gardenerId;
  final String? retailerId;

  AppointmentData({
    this.appointmentId,
    this.subject,
    this.description,
    this.appointmentDate,
    this.duration,
    this.appointmentType,
    this.status,
    this.location,
    this.gardenName,
    this.phone,
    this.address,
    this.cancellationReason,
    this.cancelledBy,
    this.createdAt,
    this.updatedAt,
    this.customerId,
    this.gardenerId,
    this.retailerId,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      appointmentId: json['appointmentId']?.toString() ?? json['appointment_id']?.toString(),
      subject: json['subject']?.toString(),
      description: json['description']?.toString(),
      appointmentDate: json['appointmentDate'] != null 
          ? DateTime.tryParse(json['appointmentDate'].toString())
          : json['appointment_date'] != null 
              ? DateTime.tryParse(json['appointment_date'].toString())
              : null,
      duration: json['duration']?.toString(),
      appointmentType: json['appointmentType']?.toString() ?? json['appointment_type']?.toString(),
      status: json['status']?.toString(),
      location: json['location']?.toString(),
      gardenName: json['gardenName']?.toString() ?? json['garden_name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      cancellationReason: json['cancellationReason']?.toString() ?? json['cancellation_reason']?.toString(),
      cancelledBy: json['cancelledBy']?.toString() ?? json['cancelled_by']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null 
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString())
          : json['updated_at'] != null 
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      customerId: json['customerId']?.toString() ?? json['customer_id']?.toString(),
      gardenerId: json['gardenerId']?.toString() ?? json['gardener_id']?.toString() ?? json['gardenId']?.toString() ?? json['garden_id']?.toString(),
      retailerId: json['retailerId']?.toString() ?? json['retailer_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'subject': subject,
      'description': description,
      'appointmentDate': appointmentDate?.toIso8601String(),
      'duration': duration,
      'appointmentType': appointmentType,
      'status': status,
      'location': location,
      'gardenName': gardenName,
      'phone': phone,
      'address': address,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customerId': customerId,
      'gardenId': gardenerId,
      'retailerId': retailerId,
    };
  }

  // Helper method to convert form data to API request format
  static Map<String, dynamic> toCreateRequest({
    required String subject,
    required String description,
    required DateTime appointmentDate,
    required int duration,
    required String appointmentType,
    String? gardenId,
    String? location,
    String? gardenName,
    String? phone,
    String? address,
  }) {
    return {
      'subject': subject,
      'description': description,
      'appointmentDate': appointmentDate.toIso8601String(),
      'duration': duration,
      'appointmentType': appointmentType,
      'gardenId': gardenId,
      'location': location ?? address,
      'gardenName': gardenName,
      'phone': phone,
      'address': address,
    };
  }
}

class CreateAppointmentRequest {
  final String subject;
  final String description;
  final DateTime appointmentDate;
  final int duration;
  final String appointmentType;
  final String gardenerId;
  final String retailerId;
  final String location;
  CreateAppointmentRequest({
    required this.subject,
    required this.description,
    required this.appointmentDate,
    required this.duration,
    required this.appointmentType,
    required this.gardenerId,
    required this.retailerId,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      'appointmentDate': appointmentDate.toIso8601String(),
      'duration': duration,
      'appointmentType': appointmentType,
      'gardenerId': gardenerId,
      'retailerId': retailerId,
      'location': location,
    };
  }
}

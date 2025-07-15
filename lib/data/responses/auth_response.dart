class AuthenticationResponse {
  final bool success;
  final String message;
  final AuthData? data;

  AuthenticationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response has a token directly (successful login)
    if (json.containsKey('token') && json['token'] != null) {
      return AuthenticationResponse(
        success: true,
        message: 'Đăng nhập thành công',
        data: AuthData.fromJson(json),
      );
    }
    
    // Check for explicit success field
    if (json.containsKey('success')) {
      return AuthenticationResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      );
    }
    
    // Check for error response
    if (json.containsKey('error') || json.containsKey('message')) {
      return AuthenticationResponse(
        success: false,
        message: json['message'] ?? json['error'] ?? 'Đăng nhập thất bại',
      );
    }
    
    // Default fallback
    return AuthenticationResponse(
      success: false,
      message: 'Phản hồi không hợp lệ từ server',
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

class AuthData {
  final String? token;
  final User? user;

  AuthData({
    this.token,
    this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      user: json.containsKey('accountId') || json.containsKey('name') 
          ? User.fromJson(json) 
          : (json['user'] != null ? User.fromJson(json['user']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
    };
  }
}

class User {
  final String? id;
  final String? accountId;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? role;
  final String? avatar;

  User({
    this.id,
    this.accountId,
    this.phoneNumber,
    this.name,
    this.email,
    this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      accountId: json['accountId'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
    };
  }
}
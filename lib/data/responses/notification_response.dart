class NotificationResponse {
  final List<NotificationModel> notifications;

  NotificationResponse({required this.notifications});

  factory NotificationResponse.fromJson(List<dynamic> json) {
    return NotificationResponse(notifications: json.map((e) => NotificationModel.fromJson(e)).toList());
  }
}

class NotificationModel {
  final String? notificationId;
  final String? message;
  final String? createdAt;
  final String? link;
  final String? sender;
  final bool? isRead;

  NotificationModel({this.notificationId, this.message, this.createdAt, this.link, this.sender, this.isRead});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],
      message: json['message'],
      createdAt: json['createdAt'],
      link: json['link'],
      sender: json['sender'],
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'message': message,
      'createdAt': createdAt,
      'link': link,
      'sender': sender,
      'isRead': isRead,
    };
  }
}

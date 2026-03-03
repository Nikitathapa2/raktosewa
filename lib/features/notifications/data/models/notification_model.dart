import '../../domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  NotificationModel({
    String? id,
    dynamic receiver,
    dynamic sender,
    required String type,
    required String message,
    String? relatedEntityId,
    required bool isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          receiver: receiver,
          sender: sender,
          type: type,
          message: message,
          relatedEntityId: relatedEntityId,
          isRead: isRead,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'],
      receiver: json['receiver'],
      sender: json['sender'],
      type: json['type'] ?? 'CAMPAIGN',
      message: json['message'] ?? '',
      relatedEntityId: json['relatedEntityId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class AppNotification {
  final String? id;
  final dynamic receiver;
  final dynamic sender;
  final String type;
  final String message;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppNotification({
    this.id,
    this.receiver,
    this.sender,
    required this.type,
    required this.message,
    this.relatedEntityId,
    required this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  AppNotification copyWith({
    String? id,
    dynamic receiver,
    dynamic sender,
    String? type,
    String? message,
    String? relatedEntityId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      receiver: receiver ?? this.receiver,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      message: message ?? this.message,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

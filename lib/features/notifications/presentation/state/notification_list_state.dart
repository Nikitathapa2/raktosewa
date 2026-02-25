import '../../domain/entities/app_notification.dart';

class NotificationListState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  NotificationListState({
    required this.notifications,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
  });

  factory NotificationListState.initial() {
    return NotificationListState(
      notifications: [],
      isLoading: false,
      hasError: false,
      errorMessage: '',
    );
  }

  NotificationListState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

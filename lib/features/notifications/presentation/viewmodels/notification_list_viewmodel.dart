import 'package:flutter/material.dart';
import '../../../../core/services/socket/socket_service.dart';
import '../../domain/usecases/get_my_notifications_usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../state/notification_list_state.dart';

class NotificationListViewmodel extends ChangeNotifier {
  final GetMyNotificationsUsecase getMyNotificationsUsecase;
  final SocketService socketService;

  NotificationListState _state = NotificationListState.initial();
  late final Function(dynamic) _notificationHandler;

  NotificationListViewmodel({
    required this.getMyNotificationsUsecase,
    required this.socketService,
  }) {
    _notificationHandler = _handleNotification;
    _setupSocketListener();
  }

  NotificationListState get state => _state;

  void _setupSocketListener() {
    socketService.onNotification(_notificationHandler);
    debugPrint('✅ Notification viewmodel listener registered');
  }

  void _handleNotification(dynamic data) {
    try {
      debugPrint('📢 Real-time notification received: $data');
      
      // Ensure data is a Map
      final Map<String, dynamic> notifData = data is Map 
          ? Map<String, dynamic>.from(data) 
          : {};
      
      // Create notification from socket data
      final notification = AppNotification(
        id: notifData['_id']?.toString(),
        receiver: notifData['receiver'],
        sender: notifData['sender'],
        type: notifData['type'] ?? 'CAMPAIGN',
        message: notifData['message'] ?? '',
        relatedEntityId: notifData['relatedEntityId']?.toString(),
        isRead: notifData['isRead'] ?? false,
        createdAt: notifData['createdAt'] != null
            ? DateTime.tryParse(notifData['createdAt'].toString())
            : DateTime.now(),
        updatedAt: notifData['updatedAt'] != null
            ? DateTime.tryParse(notifData['updatedAt'].toString())
            : null,
      );

      // Add to the top of the list
      _state = _state.copyWith(
        notifications: [notification, ..._state.notifications],
      );
      notifyListeners();
      debugPrint('✅ Notification added to list, total: ${_state.notifications.length}');
    } catch (e) {
      debugPrint('❌ Error processing notification: $e');
    }
  }

  Future<void> fetchNotifications() async {
    _state = _state.copyWith(isLoading: true, hasError: false);
    notifyListeners();

    final result = await getMyNotificationsUsecase();

    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        );
      },
      (notifications) {
        _state = _state.copyWith(
          isLoading: false,
          notifications: notifications,
          hasError: false,
        );
      },
    );

    notifyListeners();
  }

  @override
  void dispose() {
    socketService.removeNotificationCallback(_notificationHandler);
    super.dispose();
  }
}

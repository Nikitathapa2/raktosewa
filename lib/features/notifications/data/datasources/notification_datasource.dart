import '../models/notification_model.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationModel>> getMyNotifications();
}

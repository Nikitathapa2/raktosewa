import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Either<Failures, List<AppNotification>>> getMyNotifications();
}

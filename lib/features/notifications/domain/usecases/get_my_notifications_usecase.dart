import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetMyNotificationsUsecase {
  final NotificationRepository repository;

  GetMyNotificationsUsecase(this.repository);

  Future<Either<Failures, List<AppNotification>>> call() {
    return repository.getMyNotifications();
  }
}

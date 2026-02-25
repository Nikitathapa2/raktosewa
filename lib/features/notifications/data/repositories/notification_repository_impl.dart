import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final INotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<AppNotification>>> getMyNotifications() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final results = await remoteDataSource.getMyNotifications();
      return Right(results);
    } on Exception catch (e) {
      debugPrint('Error fetching notifications: ${e.toString()}');
      return Left(ServerFailure(e.toString()));
    }
  }
}

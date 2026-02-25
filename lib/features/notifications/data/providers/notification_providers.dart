import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/providers/user_aware_providers.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../../../core/services/storage/token_service.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_my_notifications_usecase.dart';
import '../datasources/notification_remote_datasource_impl.dart';
import '../datasources/notification_datasource.dart';
import '../repositories/notification_repository_impl.dart';

final notificationRemoteDataSourceProvider =
    Provider<INotificationRemoteDataSource>((ref) {
  ref.watch(sessionVersionProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final token = tokenService.getToken();

  final remoteDataSource = NotificationRemoteDataSourceImpl(
    client: http.Client(),
    token: token,
  );

  if (token != null) {
    remoteDataSource.setToken(token);
  }

  return remoteDataSource;
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return NotificationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

final getMyNotificationsUsecaseProvider =
    Provider<GetMyNotificationsUsecase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetMyNotificationsUsecase(repository);
});

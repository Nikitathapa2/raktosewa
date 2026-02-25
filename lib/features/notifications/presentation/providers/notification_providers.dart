import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/user_aware_providers.dart';
import '../../../../core/services/socket/socket_provider.dart';
import '../viewmodels/notification_list_viewmodel.dart';
import '../../data/providers/notification_providers.dart';

final notificationListViewmodelProvider =
    ChangeNotifierProvider<NotificationListViewmodel>((ref) {
  ref.watch(sessionVersionProvider);
  final getMyNotifications = ref.watch(getMyNotificationsUsecaseProvider);
  final socketService = ref.watch(socketServiceProvider);

  final viewmodel = NotificationListViewmodel(
    getMyNotificationsUsecase: getMyNotifications,
    socketService: socketService,
  );

  ref.onDispose(() {
    viewmodel.dispose();
  });

  return viewmodel;
});

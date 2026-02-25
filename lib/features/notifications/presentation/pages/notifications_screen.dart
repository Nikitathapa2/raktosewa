import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import '../../../../core/services/socket/socket_provider.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _connectAndFetchData();
  }

  void _connectAndFetchData() {
    Future.microtask(() {
      // Ensure socket is connected (should already be connected from home screen)
      final socketService = ref.read(socketServiceProvider);
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getCurrentUserId();
      
      if (userId != null && !socketService.isConnected) {
        socketService.connect(userId);
        debugPrint('🔌 Socket connected from notifications screen');
      } else {
        debugPrint('✅ Socket already connected');
      }

      // Fetch notifications
      ref.read(notificationListViewmodelProvider).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = ref.watch(notificationListViewmodelProvider);
    final state = viewmodel.state;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryRed,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEC131E)),
            )
          : state.hasError && state.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.getSecondaryTextColor(context).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.errorMessage}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(notificationListViewmodelProvider)
                              .fetchNotifications();
                        },
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : state.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppColors.getSecondaryTextColor(context).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryRed,
                      onRefresh: () async {
                        return await Future.microtask(() {
                          ref
                              .read(notificationListViewmodelProvider)
                              .fetchNotifications();
                        });
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.notifications.length,
                        itemBuilder: (context, index) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          final notification = state.notifications[index];
                          final createdAt = notification.createdAt;
                          final timeLabel = createdAt != null
                              ? DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(createdAt)
                              : 'Just now';
                          final isUnread = !notification.isRead;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.getSurfaceColor(context).withOpacity(0.7)
                                  : AppColors.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: isDark
                                  ? Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? AppColors.primaryRed
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isUnread
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: AppColors.getTextColor(context),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        timeLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.getSecondaryTextColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

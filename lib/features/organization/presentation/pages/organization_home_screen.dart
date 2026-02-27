import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:raktosewa/core/services/socket/socket_provider.dart';
import 'package:raktosewa/theme/widgets/theme_mode_toggle_button.dart';
import 'package:raktosewa/features/campaigns/presentation/pages/manage_campaign_screen.dart';
import 'package:raktosewa/features/inventory/presentation/pages/manage_inventory_screen.dart';
import 'package:raktosewa/features/organization/presentation/pages/edit_organization_profile_screen.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/features/campaigns/presentation/providers/campaign_list_providers.dart';
import 'package:raktosewa/features/blood_requests/presentation/providers/request_list_providers.dart';
import 'package:raktosewa/features/inventory/presentation/providers/inventory_viewmodel_provider.dart';
import 'package:raktosewa/features/notifications/presentation/providers/notification_providers.dart';
import 'package:raktosewa/features/organization/presentation/providers/organization_dashboard_stats_provider.dart';
import 'package:raktosewa/features/organization/presentation/state/organization_dashboard_stats_state.dart';

// Blood type status enum
enum BloodStatus { critical, low, mid, full }

class OrganizationHomeScreen extends ConsumerStatefulWidget {
  const OrganizationHomeScreen({super.key});

  @override
  ConsumerState<OrganizationHomeScreen> createState() =>
      _OrganizationHomeScreenState();
}

class _OrganizationHomeScreenState extends ConsumerState<OrganizationHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllData();
    });
  }

  void _fetchAllData() {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken() ?? '';
    
    ref.read(campaignListViewModelProvider.notifier).fetchMyCampaigns(token);
    ref.read(requestListViewModelProvider.notifier).fetchMyRequests(token);
    ref.read(inventoryViewModelProvider.notifier).fetchInventory(token);
    ref.read(notificationListViewmodelProvider).fetchNotifications();
    ref.read(organizationDashboardStatsNotifierProvider.notifier).fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch all providers
   
    final inventoryState = ref.watch(inventoryViewModelProvider);
    final notificationState = ref.watch(notificationListViewmodelProvider);
    final statsState = ref.watch(organizationDashboardStatsNotifierProvider);
    
    // Get current user
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getCurrentUserId() ?? '';

    // Socket connection
    final socketService = ref.read(socketServiceProvider);
    if (userId.isNotEmpty && !socketService.isConnected) {
      socketService.connect(userId);
    }

    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(isDark),
        
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // KPI Summary Cards
                    _buildKPISummary(isDark, statsState),
                    _buildQuickManagement(isDark),
        
                    // Blood Inventory Section
                    _buildBloodInventory(isDark, inventoryState),
        
                    // Recent Activities Section - Show Recent Notifications
                    _buildRecentActivities(isDark, notificationState),
        
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildTopAppBar(bool isDark) {
    final userSession = ref.read(userSessionServiceProvider);
    final profilePic = userSession.getProfilePicture();
    final organizatioName = userSession.getCurrentUserFullName() ?? 'Organization';
    
        return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF221011).withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEC131E).withOpacity(0.2),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        ApiEndpoints.profilePicture(profilePic ?? '')
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  organizatioName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF181111),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none, size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                  ),
                  child: const ThemeModeToggleButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISummary(bool isDark, OrganizationDashboardStatsState statsState) {
    if (statsState.isLoading && statsState.stats == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildKPICard(
                isDark,
                icon: Icons.inventory_2,
                label: 'Blood Units',
                value: '...',
                subtext: 'Loading',
                subtextColor: const Color(0xFFEC131E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                isDark,
                icon: Icons.groups,
                label: 'Donors',
                value: '...',
                subtext: 'Loading',
                subtextColor: const Color(0xFFEC131E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICardPrimary(
                isDark,
                icon: Icons.campaign,
                label: 'Campaigns',
                value: '...',
                subtext: 'Loading',
              ),
            ),
          ],
        ),
      );
    }

    if (statsState.error != null && statsState.stats == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEC131E).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFEC131E)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Could not load dashboard stats',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF181111),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(organizationDashboardStatsNotifierProvider.notifier).fetchStats();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Color(0xFFEC131E)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final stats = statsState.stats;
    if (stats == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF3F4F6),
            ),
          ),
          child: Text(
            'No dashboard stats available',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildKPICard(
              isDark,
              icon: Icons.inventory_2,
              label: 'Blood Units',
              value: stats.totalBloodUnits.toString(),
              subtext: 'In Stock',
              subtextColor: const Color(0xFF07885D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPICard(
              isDark,
              icon: Icons.groups,
              label: 'Donors',
              value: stats.totalDonorsCount.toString(),
              subtext: 'Overall',
              subtextColor: const Color(0xFFEC131E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPICardPrimary(
              isDark,
              icon: Icons.campaign,
              label: 'Campaigns',
              value: stats.totalCampaigns.toString(),
              subtext: 'Created',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
    required Color subtextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFF3F4F6),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFEC131E),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICardPrimary(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEC131E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC131E).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildBloodInventory(bool isDark, dynamic inventoryState) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Blood Inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF181111),
              ),
            ),
            const Text(
              'Live Status',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEC131E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Loading State
        if (inventoryState.isLoading && inventoryState.inventoryList.isEmpty)
          SizedBox(
            height: 120,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFFEC131E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading inventory...',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        
        // Error State
        else if (inventoryState.error != null && inventoryState.inventoryList.isEmpty)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEC131E).withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFEC131E), size: 32),
                const SizedBox(height: 8),
                Text(
                  'Could not load inventory',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF181111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  inventoryState.error ?? 'Unknown error',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _fetchAllData,
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Color(0xFFEC131E)),
                  ),
                ),
              ],
            ),
          )
        
        // Empty State
        else if (inventoryState.inventoryList.isEmpty)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 32,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No inventory data available',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add blood units to get started',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        
        // Success State - Display Inventory
        else
          _buildInventoryHorizontalList(isDark, inventoryState),
      ],
    ),
  );
}

Widget _buildInventoryHorizontalList(bool isDark, dynamic inventoryState) {
  // Map blood group inventory from real backend data
  final bloodInventoryMap = <String, int>{};
  for (var item in inventoryState.inventoryList) {
    final bloodGroup = item.bloodGroup ?? 'Unknown';
    final quantity = item.quantity ?? 0;
    bloodInventoryMap[bloodGroup] = quantity;
  }

  // All blood groups
  const allBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  return SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: allBloodGroups.length,
      itemBuilder: (context, index) {
        final bloodGroup = allBloodGroups[index];
        final units = bloodInventoryMap[bloodGroup] ?? 0;
        final status = _getBloodStatus(units);
        
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 90,
            child: _buildBloodTypeCard(
              isDark,
              bloodType: bloodGroup,
              status: status,
              units: units,
            ),
          ),
        );
      },
    ),
  );
}


  Widget _buildBloodTypeCard(
    bool isDark, {
    required String bloodType,
    required BloodStatus status,
    required int units,
  }) {
    Color statusColor = const Color(0xFFEC131E);
    String statusLabel = 'CRIT';
    double opacity = 1.0;

    switch (status) {
      case BloodStatus.critical:
        statusColor = const Color(0xFFEC131E);
        statusLabel = 'CRIT';
        opacity = 1.0;
        break;
      case BloodStatus.low:
        statusColor = const Color(0xFFEC131E);
        statusLabel = 'LOW';
        opacity = 1.0;
        break;
      case BloodStatus.mid:
        statusColor = const Color(0xFFEC131E).withOpacity(0.4);
        statusLabel = 'MID';
        opacity = 1.0;
        break;
      case BloodStatus.full:
        statusColor = Colors.grey[500]!;
        statusLabel = 'FULL';
        opacity = 0.6;
        break;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFF3F4F6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              bloodType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF181111),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$units units',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildQuickManagement(bool isDark) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF181111),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _quickManagementItem(
                isDark,
                icon: Icons.add_task,
                iconColor: const Color(0xFFEC131E),
                title: 'Campaigns',
                subtitle: 'Create & manage',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageCampaignsScreen(),
                    ),
                  );
                },
              ),
              _quickManagementItem(
                isDark,
                icon: Icons.inventory_2,
                iconColor: const Color(0xFF3B82F6),
                title: 'Inventory',
                subtitle: 'Stock update',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageInventoryScreen(),
                    ),
                  );
                },
              ),
              _quickManagementItem(
                isDark,
                icon: Icons.person,
                iconColor: const Color(0xFF10B981),
                title: 'Edit Profile',
                subtitle: 'Update details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditOrganizationProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

 Widget _quickManagementItem(
  bool isDark, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFF3F4F6),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildRecentActivities(bool isDark, dynamic notificationState) {
    final notifications = notificationState.state.notifications ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF181111),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC131E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notifications.isEmpty)
            Center(
              child: Text(
                'No recent activities',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                notifications.length > 5 ? 5 : notifications.length,
                (index) {
                  final notification = notifications[index];
                  final icon = _getNotificationIcon(notification.type);
                  final iconColor = _getNotificationColor(notification.type);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFF3F4F6),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.type ?? 'Notification',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF181111),
                                  ),
                                ),
                                Text(
                                  notification.message ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Now';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'CAMPAIGN':
        return Icons.event_available;
      case 'BLOOD_REQUEST':
        return Icons.emergency_share;
      case 'INVENTORY':
        return Icons.inventory_2;
      case 'DONATION':
        return Icons.water_drop;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'CAMPAIGN':
        return const Color(0xFFEC131E);
      case 'BLOOD_REQUEST':
        return const Color(0xFF3B82F6);
      case 'INVENTORY':
        return const Color(0xFF10B981);
      case 'DONATION':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }

  BloodStatus _getBloodStatus(int units) {
    if (units == 0) {
      return BloodStatus.critical;
    } else if (units < 3) {
      return BloodStatus.low;
    } else if (units < 10) {
      return BloodStatus.mid;
    } else {
      return BloodStatus.full;
    }
  }

 
}
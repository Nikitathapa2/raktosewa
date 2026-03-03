import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/features/campaigns/presentation/pages/manage_campaign_screen.dart';
import 'package:raktosewa/features/campaigns/presentation/providers/campaign_list_providers.dart';
import 'package:raktosewa/features/inventory/presentation/pages/manage_inventory_screen.dart';
import 'package:raktosewa/features/inventory/presentation/providers/inventory_viewmodel_provider.dart';
import 'package:raktosewa/features/organization/presentation/pages/organization_home_screen.dart';
import 'package:raktosewa/features/organization/presentation/pages/organization_profile_screen.dart';
import 'package:raktosewa/features/blood_requests/presentation/pages/manage_request_screen.dart';
import 'package:raktosewa/core/services/socket/socket_provider.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/blood_requests/presentation/providers/request_list_providers.dart';

class OrganizationDashboardScreen extends ConsumerStatefulWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  ConsumerState<OrganizationDashboardScreen> createState() =>
      _OrganizationDashboardScreenState();
}

class _OrganizationDashboardScreenState
    extends ConsumerState<OrganizationDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Connect socket once when dashboard loads
      final socketService = ref.read(socketServiceProvider);
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getCurrentUserId();
      
      if (userId != null && !socketService.isConnected) {
        socketService.connect(userId);
        debugPrint('🔌 Socket connected from OrganizationDashboard for user: $userId');
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    
    // Trigger data refresh when switching tabs
    Future.microtask(() {
      switch (index) {
        case 1: // Campaigns
          final tokenService = ref.read(tokenServiceProvider);
          final token = tokenService.getToken();
          if (token != null) {
            ref.read(campaignListViewModelProvider.notifier).fetchMyCampaigns(token);
            debugPrint('🔄 Refreshing campaigns data');
          }
          break;
        case 2: // Requests
          final tokenService = ref.read(tokenServiceProvider);
          final token = tokenService.getToken();
          if (token != null) {
            ref.read(requestListViewModelProvider.notifier).fetchMyRequests(token);
            debugPrint('🔄 Refreshing requests data');
          }
          break;
        case 3: // Inventory
          final tokenService = ref.read(tokenServiceProvider);
          final token = tokenService.getToken();
          if (token != null) {
            ref.read(inventoryViewModelProvider.notifier).fetchInventory(token);
            debugPrint('🔄 Refreshing inventory data');
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OrganizationHomeScreen(),
      const ManageCampaignsScreen(),
      const ManageRequestsScreen(),
      const ManageInventoryScreen(),
      const OrganizationProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEC131E),
        unselectedItemColor: const Color(0xFF9CA3AF),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

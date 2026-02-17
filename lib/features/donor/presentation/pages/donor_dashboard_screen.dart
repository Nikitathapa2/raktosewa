import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/blood_requests/presentation/pages/donor_blood_requests_screen.dart';
import 'package:raktosewa/features/blood_requests/presentation/providers/request_list_providers.dart';
import 'package:raktosewa/features/campaigns/presentation/providers/campaign_list_providers.dart';
import 'package:raktosewa/features/donor/presentation/pages/donor_home_screen.dart';
import 'package:raktosewa/features/donor/presentation/pages/donor_profile_screen.dart';
import 'package:raktosewa/features/campaigns/presentation/pages/donor_campaigns_screen.dart';
import 'package:raktosewa/features/inventory/presentation/pages/blood_inventory_screen.dart';
import 'package:raktosewa/features/inventory/presentation/providers/blood_stock_providers.dart';
import 'package:raktosewa/core/services/socket/socket_provider.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';

class DonorDashboardScreen extends ConsumerStatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  ConsumerState<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends ConsumerState<DonorDashboardScreen> {
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
        debugPrint('🔌 Socket connected from DonorDashboard for user: $userId');
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    
    // Trigger data refresh when switching tabs
    Future.microtask(() {
      switch (index) {
        case 0: // Home
          final tokenService = ref.read(tokenServiceProvider);
          final token = tokenService.getToken();
          if (token != null) {
            ref.read(campaignListViewModelProvider.notifier).fetchCampaigns(token);
          }
          debugPrint('🔄 Refreshing home data');
          break;
        case 1: // Campaigns
          final tokenService2 = ref.read(tokenServiceProvider);
          final token2 = tokenService2.getToken();
          if (token2 != null) {
            ref.read(campaignListViewModelProvider.notifier).fetchCampaigns(token2);
          }
          debugPrint('🔄 Refreshing campaigns data');
          break;
        case 2: // Requests
          ref.read(donorBloodRequestsProvider.notifier).getAllBloodRequests();
          debugPrint('🔄 Refreshing requests data');
          break;
        case 3: // Inventory
          final tokenService3 = ref.read(tokenServiceProvider);
          final token3 = tokenService3.getToken();
          if (token3 != null) {
            ref.read(bloodStockListNotifierProvider.notifier).getAllBloodStock(token3);
          }
          debugPrint('🔄 Refreshing inventory data');
          break;
      }
    });
  }

  late final List<Widget> _pages = [
    const DonorHomeScreen(),
    const DonorCampaignsScreen(),
    const DonorBloodRequestsScreen(),
    const BloodInventoryScreen(),
    const DonorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.getSecondaryTextColor(context),
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
            icon: Icon(Icons.volunteer_activism_outlined),
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


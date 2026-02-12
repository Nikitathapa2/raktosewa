import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/campaigns/presentation/providers/campaign_list_providers.dart';
import '../../../../widgets/top_profile.dart';
import '../../../../widgets/banner_carousel.dart';
import '../../../../widgets/blood_request_carousel.dart';
import '../../../../widgets/campaign_carousel.dart';
import '../../../../core/services/socket/socket_provider.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../../blood_requests/presentation/providers/request_list_providers.dart';

class DonorHomeScreen extends ConsumerStatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  ConsumerState<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends ConsumerState<DonorHomeScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    // Fetch blood requests and campaigns when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Connect socket
      final socketService = ref.read(socketServiceProvider);
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getCurrentUserId();
      
      if (userId != null && !socketService.isConnected) {
        socketService.connect(userId);
      }

      // Fetch data
      _fetchData();
    });
  }

  void _fetchData() {
    ref.read(donorBloodRequestsProvider.notifier).getAllBloodRequests();
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(campaignListViewModelProvider.notifier).fetchCampaigns(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch to keep the donor blood requests provider alive (prevents autoDispose)
    ref.watch(donorBloodRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopProfile(),
              const SizedBox(height: 20),
              const BannerCarousel(),
              const SizedBox(height: 28),
              const BloodRequestCarousel(),
              const SizedBox(height: 28),
              const CampaignCarousel(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}


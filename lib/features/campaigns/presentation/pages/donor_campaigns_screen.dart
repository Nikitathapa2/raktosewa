import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/utils/snackbar_utils.dart';
import 'package:raktosewa/features/campaigns/presentation/providers/campaign_list_providers.dart';
import 'package:raktosewa/features/campaigns/presentation/pages/campaign_detail_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class DonorCampaignsScreen extends ConsumerStatefulWidget {
  const DonorCampaignsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DonorCampaignsScreen> createState() => _DonorCampaignsScreenState();
}

class _DonorCampaignsScreenState extends ConsumerState<DonorCampaignsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Shake detection
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  static const double _shakeThreshold = 15.0; // Threshold for detecting shake
  static const Duration _shakeCooldown = Duration(seconds: 2); // Cooldown between shakes

  @override
  void initState() {
    super.initState();
    // Fetch campaigns when screen loads
    Future.microtask(() {
      _fetchCampaigns();
    });
    
    // Initialize shake detection
    _initializeShakeDetection();
  }

  void _initializeShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _detectShake(event);
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );
  }

  void _detectShake(AccelerometerEvent event) {
    final now = DateTime.now();
    
    // Check if cooldown period has passed
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!) < _shakeCooldown) {
      return;
    }

    // Calculate acceleration magnitude
    final x = event.x;
    final y = event.y;
    final z = event.z;
    final magnitude = sqrt(x * x + y * y + z * z);

    // Detect shake (magnitude exceeds threshold)
    if (magnitude > _shakeThreshold) {
      _lastShakeTime = now;
      _handleShakeRefresh();
    }
  }

  void _handleShakeRefresh() {
    // Trigger refresh
    _fetchCampaigns();
    
    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.refresh, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Campaign refreshed successfully'),
            ],
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _fetchCampaigns() {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(campaignListViewModelProvider.notifier).fetchCampaigns(token);
    }
  }

  void _performSearch(String query) {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(campaignListViewModelProvider.notifier).searchCampaigns(token, query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(campaignListViewModelProvider.notifier).clearSearch(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campaignState = ref.watch(campaignListViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Blood Donation Campaigns',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextColor(context),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.getBorderColor(context),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.getSurfaceColor(context),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Debounce search - only search after user stops typing for 500ms
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search campaigns by title or description...',
                hintStyle: TextStyle(color: AppColors.getSecondaryTextColor(context), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primaryRed,
                ),
                suffixIcon: campaignState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.getSecondaryTextColor(context)),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.getBackgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.getBorderColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Campaign List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final tokenService = ref.read(tokenServiceProvider);
                final token = tokenService.getToken();
                if (token != null) {
                  await ref.read(campaignListViewModelProvider.notifier).fetchCampaigns(token);
                }
              },
              child: campaignState.isLoading && campaignState.campaigns.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : campaignState.errorMessage != null && campaignState.campaigns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          campaignState.errorMessage!,
                          style: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _fetchCampaigns();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : campaignState.campaigns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              campaignState.searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.campaign_outlined,
                              size: 80,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              campaignState.searchQuery.isNotEmpty
                                  ? 'No campaigns found'
                                  : 'No campaigns available',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              campaignState.searchQuery.isNotEmpty
                                  ? 'Try adjusting your search terms'
                                  : 'Check back later for upcoming campaigns',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                            if (campaignState.searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _clearSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Clear Search'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: campaignState.campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = campaignState.campaigns[index];
                          final userSession = ref.read(userSessionServiceProvider);
                          final userId = userSession.getCurrentUserId();
                          final hasApplied = campaign.participants?.any((p) {
                            if (p is Map) return p['_id'] == userId;
                            return p == userId;
                          }) ?? false;

                          return _CampaignCard(
                            campaign: campaign,
                            hasApplied: hasApplied,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CampaignDetailScreen(campaign: campaign),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final dynamic campaign;
  final bool hasApplied;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.campaign,
    required this.hasApplied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: isDark
          ? AppColors.getSurfaceColor(context).withOpacity(0.7)
          : AppColors.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Image
            if (campaign.imageName != null && campaign.imageName!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  ApiEndpoints.campaignImage(campaign.imageName!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.campaign,
                        size: 60,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    campaign.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(campaign.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${campaign.startTime} - ${campaign.endTime}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          campaign.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Participants count and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt,
                            size: 18,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${campaign.participants?.length ?? 0} participants',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      if (hasApplied)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Registered',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

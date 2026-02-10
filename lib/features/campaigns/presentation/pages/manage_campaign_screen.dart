import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/campaign.dart';
import '../providers/campaign_list_providers.dart';
import 'create_campaign_screen.dart';
import 'campaign_participants_screen.dart';

class ManageCampaignsScreen extends ConsumerStatefulWidget {
  const ManageCampaignsScreen({super.key});

  @override
  ConsumerState<ManageCampaignsScreen> createState() =>
      _ManageCampaignsScreenState();
}

class _ManageCampaignsScreenState extends ConsumerState<ManageCampaignsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Upcoming', 'Completed'];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCampaigns();
    });
  }

  void _fetchCampaigns() {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(campaignListViewModelProvider.notifier).fetchMyCampaigns(token);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(campaignListViewModelProvider);

    ref.listen(campaignListViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final campaigns = _applyFilters(state.campaigns);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopBar(context, isDark),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and Create
                      _buildSearchAndCreate(context, isDark),
                      const SizedBox(height: 20),

                      // Filter Tabs
                      _buildFilterTabs(isDark),
                      const SizedBox(height: 20),

                      if (state.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (campaigns.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('No campaigns found'),
                          ),
                        )
                      else
                        ...campaigns.map(
                          (campaign) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCampaignCard(
                              context,
                              isDark,
                              campaign,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Campaign> _applyFilters(List<Campaign> campaigns) {
    final query = _searchController.text.trim().toLowerCase();

    return campaigns.where((campaign) {
      final matchesQuery =
          query.isEmpty ||
          campaign.title.toLowerCase().contains(query) ||
          campaign.location.toLowerCase().contains(query);

      final status = _getStatus(campaign.date);
      final matchesFilter =
          _selectedFilter == 'All' || status == _selectedFilter;

      return matchesQuery && matchesFilter;
    }).toList();
  }

  String _getStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final campaignDay = DateTime(date.year, date.month, date.day);

    if (campaignDay.isBefore(today)) return 'Completed';
    if (campaignDay.isAtSameMomentAs(today)) return 'Active';
    return 'Upcoming';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF221011).withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorderColor(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (canPop) ...[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: AppColors.getTextColor(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'Manage Campaigns',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextColor(context),
                  ),
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.getDividerColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.more_horiz,
                color: AppColors.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndCreate(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search Field
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search campaigns...',
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.getSecondaryTextColor(context),
            ),
            filled: true,
            fillColor: AppColors.getSurfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            hintStyle: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 14,
            ),
          ),
          style: TextStyle(color: AppColors.getTextColor(context)),
        ),
        const SizedBox(height: 12),

        // Create Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCampaignScreen()),
              );

              if (created == true && mounted) {
                _fetchCampaigns();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC131E),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFEC131E).withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Create New Campaign',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: AppColors.getSurfaceColor(context),
              selectedColor: const Color(0xFFEC131E),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : AppColors.getBorderColor(context),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCampaignCard(
    BuildContext context,
    bool isDark,
    Campaign campaign,
  ) {
    final status = _getStatus(campaign.date);
    final statusColor = _statusColor(status);
    final isCompleted = status == 'Completed';

    final imageUrl = campaign.imageName == null
        ? null
        : '${ApiEndpoints.mediaServerUrl}/campaigns/${campaign.imageName}';

    final participants = campaign.participants?.length ?? 0;
    final target = campaign.targetUnits ?? 0;
    final progress = target > 0
        ? ((participants / target) * 100).clamp(0, 100).toInt()
        : 0;

    final progressLabel = target > 0 ? 'Donation Progress' : 'Participants';
    final progressValue = target > 0
        ? '$participants/$target'
        : participants.toString();
    final progressUnit = target > 0 ? 'donors' : 'donors';

    return Container(
      decoration: BoxDecoration(
        color: isCompleted
            ? (isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.white.withOpacity(0.6))
            : (isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.getSurfaceColor(context)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and image
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            campaign.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF181111),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.getDividerColor(context),
                        image: imageUrl == null
                            ? null
                            : DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: imageUrl == null
                          ? const Icon(Icons.image_not_supported)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date and Location
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(campaign.date)} • ${campaign.startTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                if (campaign.location.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFFEC131E),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        campaign.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: progressValue,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                          TextSpan(
                            text: ' $progressUnit',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: target > 0 ? progress / 100 : 0,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),

          // Action Toolbar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.getBorderColor(context),
                ),
              ),
            ),
            child: Row(
              children: [
                _buildActionButton(
                  isDark,
                  Icons.edit,
                  'Edit',
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateCampaignScreen(initialCampaign: campaign),
                      ),
                    );

                    if (updated == true && mounted) {
                      _fetchCampaigns();
                    }
                  },
                ),
                _buildDivider(),
                _buildActionButton(
                  isDark,
                  Icons.delete_outline,
                  'Delete',
                  onPressed: () => _confirmDelete(campaign),
                ),
                _buildDivider(),
                _buildActionButton(
                  isDark,
                  Icons.visibility,
                  'View',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateCampaignScreen(initialCampaign: campaign),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildActionButton(
                  isDark,
                  Icons.people_alt,
                  'Participants',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CampaignParticipantsScreen(campaign: campaign),
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

  Future<void> _confirmDelete(Campaign campaign) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(campaignListViewModelProvider.notifier)
          .deleteCampaign(campaign.id ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchCampaigns();
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF10B981);
      case 'Upcoming':
        return const Color(0xFF3B82F6);
      case 'Completed':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFFEC131E);
    }
  }

  Widget _buildActionButton(
    bool isDark,
    IconData icon,
    String label, {
    VoidCallback? onPressed,
    bool disabled = false,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: disabled
                      ? const Color(0xFF9CA3AF).withOpacity(0.5)
                      : const Color(0xFF9CA3AF),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: disabled
                        ? const Color(0xFF9CA3AF).withOpacity(0.5)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 16,
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : AppColors.getBorderColor(context),
    );
  }
}

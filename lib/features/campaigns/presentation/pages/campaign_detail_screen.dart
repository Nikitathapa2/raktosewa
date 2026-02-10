import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/utils/snackbar_utils.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/campaigns/domain/entities/campaign.dart';
import 'package:raktosewa/features/campaigns/presentation/providers/campaign_list_providers.dart';
import 'package:intl/intl.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final Campaign campaign;

  const CampaignDetailScreen({
    super.key,
    required this.campaign,
  });

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  bool _isApplying = false;

  Future<void> _applyForCampaign() async {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getCurrentUserId();

    if (userId == null) {
      SnackbarUtils.showError(context, 'Please login to apply');
      return;
    }

    if (widget.campaign.id == null) {
      SnackbarUtils.showError(context, 'Invalid campaign');
      return;
    }

    setState(() {
      _isApplying = true;
    });

    final success = await ref
        .read(campaignListViewModelProvider.notifier)
        .applyForCampaign(widget.campaign.id!, userId);

    setState(() {
      _isApplying = false;
    });

    if (mounted) {
      if (success) {
        SnackbarUtils.showSuccess(
          context,
          'Successfully registered for campaign!',
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        final errorMsg = ref.read(campaignListViewModelProvider).errorMessage;
        SnackbarUtils.showError(
          context,
          errorMsg ?? 'Failed to apply for campaign',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getCurrentUserId();
    final hasApplied = widget.campaign.participants?.any((p) {
      if (p is Map) return p['_id'] == userId;
      return p == userId;
    }) ?? false;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // App Bar with Title
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryRed,
            title: const Text(
              'Campaign Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campaign Image
                if (widget.campaign.imageName != null &&
                    widget.campaign.imageName!.isNotEmpty)
                  Container(
                    height: 250,
                    width: double.infinity,
                    child: Image.network(
                      ApiEndpoints.campaignImage(widget.campaign.imageName!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.getSecondaryTextColor(context).withOpacity(0.2),
                          child: Icon(
                            Icons.campaign,
                            size: 80,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        );
                      },
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.campaign.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(context),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                  // Date and Time Card
                  _InfoCard(
                    icon: Icons.calendar_month,
                    title: 'Date & Time',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(widget.campaign.date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.campaign.startTime} - ${widget.campaign.endTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Card
                  _InfoCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    content: Text(
                      widget.campaign.location,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target Units Card
                  if (widget.campaign.targetUnits != null)
                    _InfoCard(
                      icon: Icons.local_hospital,
                      title: 'Target Blood Units',
                      content: Row(
                        children: [
                          Text(
                            '${widget.campaign.targetUnits} units',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Participants Count
                  _InfoCard(
                    icon: Icons.people_alt,
                    title: 'Registered Participants',
                    content: Text(
                      '${widget.campaign.participants?.length ?? 0} people',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'About This Campaign',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.getBorderColor(context),
                      ),
                    ),
                    child: Text(
                      widget.campaign.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.getSecondaryTextColor(context),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
              ],
            ),
          ),
        ],
      ),

      // Apply Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: hasApplied
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Already Registered',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _applyForCampaign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isApplying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.volunteer_activism, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Register for Campaign',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.getSurfaceColor(context).withOpacity(0.7)
            : AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getBorderColor(context),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import '../features/campaigns/presentation/pages/donor_campaigns_screen.dart';
import '../features/campaigns/presentation/pages/campaign_detail_screen.dart';
import '../features/campaigns/presentation/providers/campaign_list_providers.dart';
import '../widgets/campaign_card_horizontal.dart';

class CampaignCarousel extends ConsumerWidget {
  const CampaignCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignState = ref.watch(campaignListViewModelProvider);

    // Get first 5 campaigns
    final campaigns = campaignState.campaigns.take(5).toList();

    if (campaignState.isLoading) {
      return SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFEC131E),
          ),
        ),
      );
    }

    if (campaigns.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No campaigns available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with View All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Upcoming Campaigns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:  AppColors.getTextColor(context),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorCampaignsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC131E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: campaigns
                .map(
                  (campaign) => CampaignCardHorizontal(
                    campaign: campaign,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampaignDetailScreen(
                            campaign: campaign,
                          ),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

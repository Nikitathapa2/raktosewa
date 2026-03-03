import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import '../features/campaigns/domain/entities/campaign.dart';

class CampaignCardHorizontal extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const CampaignCardHorizontal({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd');
    final campaignDate = dateFormat.format(campaign.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark 
            ? AppColors.getSurfaceColor(context).withOpacity(0.7)
            : AppColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(context),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign image or placeholder
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryRed,
                    AppColors.primaryRed.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: campaign.imageName != null
                  ? Image.network(
                      ApiEndpoints.campaignImage(campaign.imageName!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),

            // Campaign details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Date and time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        campaignDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        campaign.startTime.length > 5
                            ? campaign.startTime.substring(0, 5)
                            : campaign.startTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          campaign.location,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Participants count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${campaign.participants?.length ?? 0} registered',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Stack(
      children: [
        Positioned(
          right: -40,
          top: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ),
        Center(
          child: Icon(
            Icons.bloodtype_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

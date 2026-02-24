import '../../domain/entities/organization_dashboard_stats.dart';

class OrganizationDashboardStatsModel {
  final int totalBloodUnits;
  final int totalDonorsCount;
  final int totalCampaigns;

  const OrganizationDashboardStatsModel({
    required this.totalBloodUnits,
    required this.totalDonorsCount,
    required this.totalCampaigns,
  });

  factory OrganizationDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return OrganizationDashboardStatsModel(
      totalBloodUnits: (json['totalBloodUnits'] as num?)?.toInt() ?? 0,
      totalDonorsCount: (json['totalDonorsCount'] as num?)?.toInt() ?? 0,
      totalCampaigns: (json['totalCampaigns'] as num?)?.toInt() ?? 0,
    );
  }

  OrganizationDashboardStats toEntity() {
    return OrganizationDashboardStats(
      totalBloodUnits: totalBloodUnits,
      totalDonorsCount: totalDonorsCount,
      totalCampaigns: totalCampaigns,
    );
  }
}

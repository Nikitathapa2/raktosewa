import '../../domain/entities/campaign.dart';

class CampaignListState {
  final bool isLoading;
  final List<Campaign> campaigns;
  final String? errorMessage;
  final String searchQuery;
  final String? locationFilter;
  final String sortBy;

  CampaignListState({
    this.isLoading = false,
    this.campaigns = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.locationFilter,
    this.sortBy = 'date',
  });

  CampaignListState copyWith({
    bool? isLoading,
    List<Campaign>? campaigns,
    String? errorMessage,
    String? searchQuery,
    String? locationFilter,
    String? sortBy,
  }) {
    return CampaignListState(
      isLoading: isLoading ?? this.isLoading,
      campaigns: campaigns ?? this.campaigns,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      locationFilter: locationFilter ?? this.locationFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/user_aware_providers.dart';
import '../../domain/usecases/delete_campaign_usecase.dart';
import '../../domain/usecases/get_all_campaigns_usecase.dart';
import '../../domain/usecases/get_my_campaigns_usecase.dart';
import '../../domain/usecases/apply_for_campaign_usecase.dart';
import '../state/campaign_list_state.dart';
import '../../data/providers/campaign_providers.dart' as data_providers;

class CampaignListNotifier extends Notifier<CampaignListState> {
  late GetAllCampaignsUsecase _getAllUsecase;
  late GetMyCampaignsUsecase _getMyUsecase;
  late DeleteCampaignUsecase _deleteUsecase;
  late ApplyForCampaignUsecase _applyUsecase;

  @override
  CampaignListState build() {
    _getAllUsecase = ref.read(data_providers.getAllCampaignsProvider);
    _getMyUsecase = ref.read(data_providers.getMyCampaignsProvider);
    _deleteUsecase = ref.read(data_providers.deleteCampaignProvider);
    _applyUsecase = ref.read(data_providers.applyForCampaignProvider);
    return CampaignListState();
  }

  Future<void> fetchCampaigns(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getAllUsecase(
      token,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      location: state.locationFilter,
      sortBy: state.sortBy,
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (campaigns) {
        state = state.copyWith(
          isLoading: false,
          campaigns: campaigns,
        );
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> searchCampaigns(String token, String query) async {
    setSearchQuery(query);
    await fetchCampaigns(token);
  }

  void clearSearch(String token) {
    state = state.copyWith(searchQuery: '');
    fetchCampaigns(token);
  }

  Future<void> fetchMyCampaigns(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getMyUsecase(token);
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (campaigns) {
        state = state.copyWith(
          isLoading: false,
          campaigns: campaigns,
        );
      },
    );
  }

  Future<void> deleteCampaign(String campaignId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _deleteUsecase(campaignId);
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }
  
  Future<bool> applyForCampaign(String campaignId, String donorId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _applyUsecase(campaignId: campaignId, donorId: donorId);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (campaign) {
        // Update the campaign in the list
        final updatedCampaigns = state.campaigns.map((c) {
          if (c.id == campaignId) {
            return campaign;
          }
          return c;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          campaigns: updatedCampaigns,
        );
        return true;
      },
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/usecases/create_campaign_usecase.dart';
import '../../domain/usecases/update_campaign_usecase.dart';
import '../state/create_campaign_state.dart';
import '../../data/providers/campaign_providers.dart' as data_providers;

class CreateCampaignNotifier extends Notifier<CreateCampaignState> {
  late CreateCampaignUsecase _createUsecase;
  late UpdateCampaignUsecase _updateUsecase;

  @override
  CreateCampaignState build() {
    _createUsecase = ref.read(data_providers.createCampaignProvider);
    _updateUsecase = ref.read(data_providers.updateCampaignProvider);
    return CreateCampaignState();
  }

  Future<void> createCampaign(
    Campaign campaign,
    String token, {
    String? imagePath,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
      createdCampaign: null,
    );

    final result = await _createUsecase(campaign, token, imagePath: imagePath);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          isSuccess: false,
        );
      },
      (createdCampaign) {
        state = state.copyWith(
          isLoading: false,
          createdCampaign: createdCampaign,
          isSuccess: true,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> updateCampaign(
    String campaignId,
    Campaign campaign,
    String token, {
    String? imagePath,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
      createdCampaign: null,
    );

    final result = await _updateUsecase(
      campaignId,
      campaign,
      token,
      imagePath: imagePath,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          isSuccess: false,
        );
      },
      (updatedCampaign) {
        state = state.copyWith(
          isLoading: false,
          createdCampaign: updatedCampaign,
          isSuccess: true,
          errorMessage: null,
        );
      },
    );
  }

  void resetState() {
    state = CreateCampaignState();
  }
}

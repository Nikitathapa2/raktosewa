import '../../domain/entities/campaign.dart';

class CreateCampaignState {
  final bool isLoading;
  final Campaign? createdCampaign;
  final String? errorMessage;
  final bool isSuccess;

  CreateCampaignState({
    this.isLoading = false,
    this.createdCampaign,
    this.errorMessage,
    this.isSuccess = false,
  });

  CreateCampaignState copyWith({
    bool? isLoading,
    Campaign? createdCampaign,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CreateCampaignState(
      isLoading: isLoading ?? this.isLoading,
      createdCampaign: createdCampaign ?? this.createdCampaign,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

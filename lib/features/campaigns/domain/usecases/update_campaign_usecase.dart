import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class UpdateCampaignUsecase {
  final CampaignRepository repository;

  UpdateCampaignUsecase(this.repository);

  Future<Either<Failures, Campaign>> call(
    String campaignId,
    Campaign campaign,
    String token, {
    String? imagePath,
  }) {
    return repository.updateCampaign(
      campaignId,
      campaign,
      token,
      imagePath: imagePath,
    );
  }
}

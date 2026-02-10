import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class CreateCampaignUsecase {
  final CampaignRepository repository;

  CreateCampaignUsecase(this.repository);

  Future<Either<Failures, Campaign>> call(
    Campaign campaign,
    String token, {
    String? imagePath,
  }) {
    return repository.createCampaign(campaign, token, imagePath: imagePath);
  }
}

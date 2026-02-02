import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class ApplyForCampaignUsecase {
  final CampaignRepository repository;

  ApplyForCampaignUsecase({required this.repository});

  Future<Either<Failures, Campaign>> call({
    required String campaignId,
    required String donorId,
  }) async {
    return await repository.applyForCampaign(campaignId, donorId);
  }
}

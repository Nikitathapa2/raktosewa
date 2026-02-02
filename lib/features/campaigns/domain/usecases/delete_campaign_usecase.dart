import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/campaign_repository.dart';

class DeleteCampaignUsecase {
  final CampaignRepository repository;

  DeleteCampaignUsecase(this.repository);

  Future<Either<Failures, void>> call(String campaignId) {
    return repository.deleteCampaign(campaignId);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class GetMyCampaignsUsecase {
  final CampaignRepository repository;

  GetMyCampaignsUsecase(this.repository);

  Future<Either<Failures, List<Campaign>>> call(String token) {
    return repository.getMyCampaigns(token);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class GetAllCampaignsUsecase {
  final CampaignRepository repository;

  GetAllCampaignsUsecase(this.repository);

  Future<Either<Failures, List<Campaign>>> call(
    String token, {
    String? search,
    String? location,
    String? sortBy,
  }) {
    return repository.getAllCampaigns(
      token,
      search: search,
      location: location,
      sortBy: sortBy,
    );
  }
}

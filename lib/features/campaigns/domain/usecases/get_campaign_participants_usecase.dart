import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/campaign_repository.dart';

class GetCampaignParticipantsUsecase {
  final CampaignRepository repository;

  GetCampaignParticipantsUsecase(this.repository);

  Future<Either<Failures, List<dynamic>>> call(String campaignId) async {
    return await repository.getCampaignParticipants(campaignId);
  }
}

class DeleteCampaignParticipantUsecase {
  final CampaignRepository repository;

  DeleteCampaignParticipantUsecase(this.repository);

  Future<Either<Failures, void>> call(String campaignId, String participantId) async {
    return await repository.deleteCampaignParticipant(campaignId, participantId);
  }
}

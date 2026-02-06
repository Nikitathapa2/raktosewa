import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/create_campaign_viewmodel.dart';
import '../state/create_campaign_state.dart';

// -------------------- ViewModel Provider --------------------
final createCampaignViewModelProvider =
    NotifierProvider<CreateCampaignNotifier, CreateCampaignState>(
  CreateCampaignNotifier.new,
);

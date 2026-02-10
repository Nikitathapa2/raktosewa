import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/campaign_list_viewmodel.dart';
import '../state/campaign_list_state.dart';

final campaignListViewModelProvider =
    NotifierProvider<CampaignListNotifier, CampaignListState>(
  CampaignListNotifier.new,
);

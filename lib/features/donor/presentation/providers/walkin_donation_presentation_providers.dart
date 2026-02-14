import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/register_walkin_donation_viewmodel.dart';
import '../state/register_walkin_donation_state.dart';

// -------------------- ViewModel Provider --------------------
final registerWalkinDonationViewModelProvider =
    NotifierProvider<RegisterWalkinDonationNotifier, RegisterWalkinDonationState>(
  RegisterWalkinDonationNotifier.new,
);

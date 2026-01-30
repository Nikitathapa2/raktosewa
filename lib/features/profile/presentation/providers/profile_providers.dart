import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import '../../domain/usecases/get_donor_profile.dart';
import '../../domain/usecases/update_donor_profile.dart';
import '../../domain/usecases/get_organization_profile.dart';
import '../../domain/usecases/update_organization_profile.dart';
import '../view_model/donor_profile_viewmodel.dart';
import '../view_model/organization_profile_viewmodel.dart';
import '../state/donor_profile_state.dart';
import '../state/organization_profile_state.dart';

// Usecases wired to existing auth repositories
final getDonorProfileProvider = Provider<GetDonorProfile>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return GetDonorProfile(repo);
});

final updateDonorProfileProvider = Provider<UpdateDonorProfile>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return UpdateDonorProfile(repo);
});

final getOrganizationProfileProvider = Provider<GetOrganizationProfile>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return GetOrganizationProfile(repo);
});

final updateOrganizationProfileProvider = Provider<UpdateOrganizationProfile>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return UpdateOrganizationProfile(repo);
});

// ViewModels
final donorProfileViewModelProvider = NotifierProvider<DonorProfileViewModel, DonorProfileState>(
  DonorProfileViewModel.new,
);

final organizationProfileViewModelProvider = NotifierProvider<OrganizationProfileViewModel, OrganizationProfileState>(
  OrganizationProfileViewModel.new,
);

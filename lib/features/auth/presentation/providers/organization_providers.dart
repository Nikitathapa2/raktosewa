import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/connectivity/network_info.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/remote/organization_remote_datasourceImp.dart';
import 'package:raktosewa/features/auth/data/providers/auth_local_providers.dart';
import '../../data/repository/organization_repository_impl.dart';
import '../../domain/usecases/register_organization_usecase.dart';
import '../../domain/usecases/login_organization_usecase.dart';
import '../../domain/usecases/logout_organization_usecase.dart';
import '../state/organization_state.dart';
import '../view_model/organization_viewmodel.dart';

final organizationRepositoryProvider = Provider<OrganizationRepositoryImpl>(
  (ref) {
    final local = ref.read(organizationLocalDatasourceProvider);
    final remote = ref.read(organizationUserRemoteProvider);
    final networkInfo = ref.read(networkInfoProvider);
    final userSessionService = ref.read(userSessionServiceProvider);
    return OrganizationRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
      networkInfo: networkInfo,
      userSessionService: userSessionService,
    );
  },
);

final registerOrganizationProvider = Provider<RegisterOrganizationUsecase>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return RegisterOrganizationUsecase(repo);
});

final loginOrganizationProvider = Provider<LoginOrganizationUsecase>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return LoginOrganizationUsecase(repo);
});

final logoutOrganizationProvider = Provider<LogoutOrganizationUsecase>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return LogoutOrganizationUsecase(repo);
});

final organizationViewModelProvider =
    NotifierProvider<OrganizationViewModel, OrganizationState>(
  OrganizationViewModel.new,
);

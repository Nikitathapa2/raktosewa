import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:raktosewa/core/constants/hive_table_constant.dart';
import 'package:raktosewa/core/services/connectivity/network_info.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/remote/organization_remote_datasourceImp.dart';
import '../../data/models/organization_model.dart';
import '../../data/datasources/local/organization_local_datasource_impl.dart';
import '../../data/repository/organization_repository_impl.dart';
import '../../domain/usecases/register_organization.dart';
import '../../domain/usecases/login_organization.dart';
import '../../domain/usecases/logout_organization.dart';
import '../state/organization_state.dart';
import '../view_model/organization_viewmodel.dart';

final organizationBoxProvider = Provider<Box<OrganizationModel>>((ref) {
  return Hive.box<OrganizationModel>(HiveTableConstant.organizationTable);
});

final organizationLocalDatasourceProvider =
    Provider<OrganizationLocalDataSourceImpl>((ref) {
  final box = ref.read(organizationBoxProvider);
  return OrganizationLocalDataSourceImpl(
    box,
    ref.read(userSessionServiceProvider),
  );
});

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

final registerOrganizationProvider = Provider<RegisterOrganization>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return RegisterOrganization(repo);
});

final loginOrganizationProvider = Provider<LoginOrganization>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return LoginOrganization(repo);
});

final logoutOrganizationProvider = Provider<LogoutOrganizationUsecase>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  return LogoutOrganizationUsecase(repo);
});

final organizationViewModelProvider =
    NotifierProvider<OrganizationViewModel, OrganizationState>(
  OrganizationViewModel.new,
);

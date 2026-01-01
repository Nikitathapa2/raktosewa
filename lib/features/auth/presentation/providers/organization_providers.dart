import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:raktosewa/core/constants/hive_table_constant.dart';
import '../../data/models/organization_model.dart';
import '../../data/datasources/local/organization_local_datasource_impl.dart';
import '../../data/repository/organization_repository_impl.dart';
import '../../domain/usecases/register_organization.dart';
import '../../domain/usecases/login_organization.dart';
import '../state/organization_state.dart';
import '../view_model/organization_viewmodel.dart';

final organizationBoxProvider = Provider<Box<OrganizationModel>>((ref) {
  return Hive.box<OrganizationModel>(HiveTableConstant.organizationTable);
});

final organizationLocalDatasourceProvider =
    Provider<OrganizationLocalDataSourceImpl>((ref) {
  final box = ref.read(organizationBoxProvider);
  return OrganizationLocalDataSourceImpl(box);
});

final organizationRepositoryProvider = Provider<OrganizationRepositoryImpl>(
  (ref) {
    final local = ref.read(organizationLocalDatasourceProvider);
    return OrganizationRepositoryImpl(localDataSource: local);
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

final organizationViewModelProvider =
    NotifierProvider<OrganizationViewModel, OrganizationState>(
  OrganizationViewModel.new,
);

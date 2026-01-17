import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/connectivity/network_info.dart';
import 'package:raktosewa/core/services/hive/hive_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/remote/donor_remote_datasourceImp.dart';
import 'package:raktosewa/features/auth/data/repository/donor_repository_impl.dart';
import '../../data/datasources/local/donor_local_datasource_impl.dart';
import '../../domain/usecases/register_donor.dart';
import '../../domain/usecases/login_donor.dart';
import '../state/donor_state.dart';
import '../view_model/donor_viewmodel.dart';

// -------------------- Donor Hive Box Provider --------------------
final donorBoxProvider = Provider<DonorHiveService>((ref) {
  return DonorHiveService();
});

// -------------------- Donor Local Datasource Provider --------------------
final donorLocalDatasourceProvider = Provider<DonorLocalDataSourceImpl>((ref) {
  final box = ref.read(donorBoxProvider);
  return DonorLocalDataSourceImpl(box, ref.read(userSessionServiceProvider));
});

// -------------------- Donor Repository Provider --------------------
final donorRepositoryProvider = Provider<DonorRepositoryImpl>((ref) {
  final local = ref.read(donorLocalDatasourceProvider);
  final remote = ref.read(donorUserRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return DonorRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
    networkInfo: networkInfo,
    userSessionService: userSessionService,
  );
});

// -------------------- Donor Usecase Providers --------------------
final registerDonorProvider = Provider<RegisterDonor>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return RegisterDonor(repo);
});

final loginDonorProvider = Provider<LoginDonor>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return LoginDonor(repo);
});

// -------------------- Donor ViewModel Provider --------------------
final donorViewModelProvider = NotifierProvider<DonorViewModel, DonorState>(
  DonorViewModel.new,
);


